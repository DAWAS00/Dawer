import uuid
from contextlib import asynccontextmanager
from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException, Query, status
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse

from shared.db import close_pool, get_pool
from shared.errors import error_response, not_found_handler, unhandled_handler
from shared.firebase import verify_token
from shared.firestore_mirror import mirror_order
from shared.pubsub import publish_order_event

from .models import (
    CreateOrderRequest,
    Order,
    OrderListResponse,
    PatchOrderStatusRequest,
    ProofPhotoResponse,
)
from .queries import (
    db_create_order,
    db_get_order,
    db_get_user_by_firebase_uid,
    db_list_orders,
    db_patch_order_status,
)

VALID_TRANSITIONS = {
    "pending": {"accepted", "cancelled"},
    "accepted": {"inTransit", "cancelled"},
    "inTransit": {"completed", "cancelled"},
}


@asynccontextmanager
async def lifespan(app: FastAPI):
    yield
    await close_pool()


app = FastAPI(title="order-svc", version="1.0.0", lifespan=lifespan)
app.add_exception_handler(404, not_found_handler)
app.add_exception_handler(500, unhandled_handler)

TokenDep = Annotated[dict, Depends(verify_token)]


@app.post("/orders", response_model=Order, status_code=status.HTTP_201_CREATED)
async def create_order(body: CreateOrderRequest, token: TokenDep):
    pool = await get_pool()
    user = await db_get_user_by_firebase_uid(pool, token["uid"])
    if not user:
        raise HTTPException(status_code=404, detail="User profile not found")

    order = await db_create_order(pool, body, creator_id=user["id"], creator_role=user["role"])
    order_dict = dict(order)

    try:
        await mirror_order(str(order_dict["id"]), order_dict)
        publish_order_event(str(order_dict["id"]), "pending", order_dict)
    except Exception:
        pass  # Firestore/Pub/Sub failure must not fail the order creation

    return order_dict


@app.get("/orders", response_model=OrderListResponse)
async def list_orders(
    token: TokenDep,
    role: str | None = Query(None),
    order_status: str | None = Query(None, alias="status"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
):
    pool = await get_pool()
    user = await db_get_user_by_firebase_uid(pool, token["uid"])
    if not user:
        raise HTTPException(status_code=404, detail="User profile not found")

    orders, total = await db_list_orders(
        pool, user_id=user["id"], user_role=user["role"],
        filter_status=order_status, page=page, page_size=page_size,
    )
    return {"items": [dict(o) for o in orders], "total": total, "page": page, "page_size": page_size}


@app.get("/orders/{order_id}", response_model=Order)
async def get_order(order_id: str, token: TokenDep):
    pool = await get_pool()
    user = await db_get_user_by_firebase_uid(pool, token["uid"])
    order = await db_get_order(pool, order_id)

    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    o = dict(order)
    uid = user["id"] if user else None
    if uid not in (o.get("supplier_id"), o.get("driver_id"), o.get("company_id")):
        if o["status"] != "pending":
            raise HTTPException(status_code=403, detail="Access denied")

    return o


@app.patch("/orders/{order_id}/status", response_model=Order)
async def patch_order_status(order_id: str, body: PatchOrderStatusRequest, token: TokenDep):
    pool = await get_pool()
    user = await db_get_user_by_firebase_uid(pool, token["uid"])
    if not user:
        raise HTTPException(status_code=404, detail="User profile not found")

    order = await db_get_order(pool, order_id)
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    o = dict(order)
    current_status = o["status"]

    if body.status not in VALID_TRANSITIONS.get(current_status, set()):
        return JSONResponse(
            status_code=status.HTTP_409_CONFLICT,
            content={
                "error": {"code": "INVALID_TRANSITION", "message": f"Cannot transition {current_status} → {body.status}"},
                "current_state": o,
            },
        )

    updated = await db_patch_order_status(
        pool, order_id=order_id, new_status=body.status,
        driver_id=str(user["id"]) if body.status == "accepted" else None,
        proof_photo_url=body.proof_photo_upload_token,
    )
    updated_dict = dict(updated)

    try:
        await mirror_order(order_id, updated_dict)
        publish_order_event(order_id, body.status, updated_dict)
    except Exception:
        pass

    return updated_dict


@app.post("/orders/{order_id}/proof-photo", response_model=ProofPhotoResponse)
async def get_proof_photo_upload_url(order_id: str, token: TokenDep):
    from google.cloud import storage
    import datetime, os

    pool = await get_pool()
    order = await db_get_order(pool, order_id)
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    bucket_name = f"{os.environ.get('GCP_PROJECT', 'dawer-prod')}-proof-photos"
    blob_name = f"{order_id}/{uuid.uuid4()}.jpg"

    client = storage.Client()
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(blob_name)

    signed_url = blob.generate_signed_url(
        version="v4",
        expiration=datetime.timedelta(minutes=15),
        method="PUT",
        content_type="image/jpeg",
    )
    return {"upload_url": signed_url, "proof_photo_upload_token": blob_name}
