from datetime import datetime
from typing import Any
from uuid import UUID

from pydantic import BaseModel, Field


class CreateOrderRequest(BaseModel):
    type: str
    waste_types: list[str]
    waste_form: str | None = None
    weight_category: str | None = None
    pickup_target: str = "company"
    pickup_lat: float
    pickup_lng: float
    estimated_weight_kg: float = 0
    distance_km: float = 0
    reward_jd: float = 0
    is_urgent: bool = False
    notes: str | None = None
    is_marketplace_shared: bool = False
    requires_rider: bool = False
    required_vehicle_type: str | None = None
    requires_chemical_permit: bool = False
    job_description: str | None = None
    payment_model: str | None = None
    price_per_kg: float | None = None
    item_price: float | None = None
    min_quantity_kg: float | None = None
    collection_delivery_method: str | None = None


class PatchOrderStatusRequest(BaseModel):
    status: str
    proof_photo_upload_token: str | None = None


class Order(BaseModel):
    id: UUID
    type: str
    status: str
    supplier_id: UUID | None = None
    driver_id: UUID | None = None
    company_id: UUID | None = None
    waste_types: list[str]
    reward_jd: float
    is_urgent: bool
    created_at: datetime
    updated_at: datetime
    accepted_at: datetime | None = None
    in_transit_at: datetime | None = None
    completed_at: datetime | None = None
    proof_photo_url: str | None = None

    class Config:
        from_attributes = True


class OrderListResponse(BaseModel):
    items: list[Order]
    total: int
    page: int
    page_size: int


class ProofPhotoResponse(BaseModel):
    upload_url: str
    proof_photo_upload_token: str
