"""notif-svc — internal only, triggered by Cloud Pub/Sub push subscription.
Receives order-events messages and dispatches FCM push notifications.
"""
import base64
import json
import os
from contextlib import asynccontextmanager

import firebase_admin
from firebase_admin import credentials, messaging
from fastapi import FastAPI, HTTPException, Request, status
from google.cloud import secretmanager

from shared.db import close_pool, get_pool
from shared.errors import unhandled_handler

NOTIFICATION_TEMPLATES = {
    "pending":    ("طلب جديد متاح 🚛", "يوجد طلب استلام جديد بالقرب منك"),
    "accepted":   ("تم قبول طلبك ✅", "السائق في طريقه إليك"),
    "inTransit":  ("طلبك في الطريق 🚗", "السائق يتجه إلى نقطة التسليم"),
    "completed":  ("تم إتمام الطلب 🎉", "تم تسليم طلبك بنجاح"),
    "cancelled":  ("تم إلغاء الطلب ❌", "تم إلغاء الطلب"),
}


def _init_firebase():
    try:
        firebase_admin.get_app()
    except ValueError:
        project_id = os.environ.get("GCP_PROJECT", "dawer-prod")
        client = secretmanager.SecretManagerServiceClient()
        resp = client.access_secret_version(
            name=f"projects/{project_id}/secrets/firebase-admin-sdk/versions/latest"
        )
        cred = credentials.Certificate(json.loads(resp.payload.data.decode()))
        firebase_admin.initialize_app(cred)


@asynccontextmanager
async def lifespan(app: FastAPI):
    _init_firebase()
    yield
    await close_pool()


app = FastAPI(title="notif-svc", version="1.0.0", lifespan=lifespan)
app.add_exception_handler(500, unhandled_handler)

INTERNAL_TOKEN = os.environ.get("INTERNAL_TOKEN", "")


@app.post("/pubsub/push")
async def handle_pubsub_push(request: Request):
    """Cloud Pub/Sub push endpoint — receives order-events messages."""
    body = await request.json()
    envelope = body.get("message", {})
    data_b64 = envelope.get("data", "")

    try:
        payload = json.loads(base64.b64decode(data_b64).decode())
    except Exception:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid Pub/Sub payload")

    order_id = payload.get("order_id")
    new_status = payload.get("status")
    order = payload.get("order", {})

    if not order_id or not new_status:
        return {"status": "ignored"}

    title, body_text = NOTIFICATION_TEMPLATES.get(new_status, ("تحديث الطلب", ""))

    pool = await get_pool()

    # Determine who to notify based on status transition
    recipient_ids = []
    if new_status == "pending":
        pass  # notif-svc doesn't fan-out to all drivers — geo-svc + FCM data message handles discovery
    elif new_status in ("accepted", "inTransit", "completed", "cancelled"):
        supplier_id = order.get("supplier_id")
        if supplier_id:
            recipient_ids.append(supplier_id)

    for recipient_id in recipient_ids:
        row = await pool.fetchrow(
            "SELECT fcm_token FROM public.users WHERE id = $1::uuid AND fcm_token IS NOT NULL",
            recipient_id,
        )
        if not row:
            continue

        fcm_token = row["fcm_token"]
        try:
            message = messaging.Message(
                notification=messaging.Notification(title=title, body=body_text),
                data={"order_id": order_id, "status": new_status},
                token=fcm_token,
                android=messaging.AndroidConfig(priority="high"),
            )
            messaging.send(message)
        except messaging.UnregisteredError:
            # Stale FCM token — clear it
            await pool.execute(
                "UPDATE public.users SET fcm_token = NULL WHERE id = $1::uuid",
                recipient_id,
            )

    return {"status": "ok"}


@app.get("/health")
async def health():
    return {"status": "ok"}
