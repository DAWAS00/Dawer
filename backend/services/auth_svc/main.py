from contextlib import asynccontextmanager
from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException, status

from shared.db import close_pool, get_pool
from shared.errors import not_found_handler, unhandled_handler
from shared.firebase import verify_token

from .models import CreateProfileRequest, UpdateFcmTokenRequest, UpdateProfileRequest, UserProfile
from .queries import (
    db_create_user,
    db_get_user_by_firebase_uid,
    db_toggle_availability,
    db_update_fcm_token,
    db_update_user,
)


@asynccontextmanager
async def lifespan(app: FastAPI):
    yield
    await close_pool()


app = FastAPI(title="auth-svc", version="1.0.0", lifespan=lifespan)
app.add_exception_handler(404, not_found_handler)
app.add_exception_handler(500, unhandled_handler)

TokenDep = Annotated[dict, Depends(verify_token)]


@app.post("/users/profile", response_model=UserProfile, status_code=status.HTTP_201_CREATED)
async def create_profile(body: CreateProfileRequest, token: TokenDep):
    """Idempotent — safe to retry. Returns existing profile if already created."""
    pool = await get_pool()
    existing = await db_get_user_by_firebase_uid(pool, token["uid"])
    if existing:
        return dict(existing)

    phone = token.get("phone_number") or body.phone
    if not phone:
        raise HTTPException(status_code=400, detail="Phone number required")

    user = await db_create_user(pool, firebase_uid=token["uid"], phone=phone, body=body)
    return dict(user)


@app.get("/users/me", response_model=UserProfile)
async def get_me(token: TokenDep):
    pool = await get_pool()
    user = await db_get_user_by_firebase_uid(pool, token["uid"])
    if not user:
        raise HTTPException(status_code=404, detail="Profile not found")
    return dict(user)


@app.patch("/users/me", response_model=UserProfile)
async def update_me(body: UpdateProfileRequest, token: TokenDep):
    pool = await get_pool()
    user = await db_get_user_by_firebase_uid(pool, token["uid"])
    if not user:
        raise HTTPException(status_code=404, detail="Profile not found")
    updated = await db_update_user(pool, user_id=str(user["id"]), body=body)
    return dict(updated)


@app.patch("/users/me/fcm-token", status_code=status.HTTP_204_NO_CONTENT)
async def update_fcm_token(body: UpdateFcmTokenRequest, token: TokenDep):
    pool = await get_pool()
    user = await db_get_user_by_firebase_uid(pool, token["uid"])
    if not user:
        raise HTTPException(status_code=404, detail="Profile not found")
    await db_update_fcm_token(pool, user_id=str(user["id"]), fcm_token=body.fcm_token)


@app.patch("/users/me/availability", status_code=status.HTTP_204_NO_CONTENT)
async def toggle_availability(token: TokenDep):
    pool = await get_pool()
    user = await db_get_user_by_firebase_uid(pool, token["uid"])
    if not user:
        raise HTTPException(status_code=404, detail="Profile not found")
    if user["role"] != "driver":
        raise HTTPException(status_code=403, detail="Only drivers can toggle availability")
    await db_toggle_availability(pool, user_id=str(user["id"]))
