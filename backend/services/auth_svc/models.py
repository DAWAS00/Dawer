from datetime import datetime
from uuid import UUID
from pydantic import BaseModel


class CreateProfileRequest(BaseModel):
    name: str
    role: str
    phone: str | None = None
    supplier_type: str | None = None
    vehicle_model: str | None = None
    vehicle_color: str | None = None
    vehicle_plate: str | None = None
    vehicle_type: str | None = None
    address: str | None = None


class UpdateProfileRequest(BaseModel):
    name: str | None = None
    address: str | None = None
    vehicle_model: str | None = None
    vehicle_color: str | None = None
    vehicle_plate: str | None = None
    vehicle_type: str | None = None
    profile_photo_url: str | None = None


class UpdateFcmTokenRequest(BaseModel):
    fcm_token: str


class UserProfile(BaseModel):
    id: UUID
    firebase_uid: str
    name: str
    phone: str
    email: str | None = None
    role: str
    supplier_type: str | None = None
    rating: float
    total_orders: int
    is_verified: bool
    is_available: bool
    points: int
    vehicle_type: str | None = None
    vehicle_model: str | None = None
    vehicle_color: str | None = None
    vehicle_plate: str | None = None
    address: str | None = None
    profile_photo_url: str | None = None
    fcm_token: str | None = None
    created_at: datetime

    class Config:
        from_attributes = True
