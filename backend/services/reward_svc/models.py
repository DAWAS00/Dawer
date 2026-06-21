from pydantic import BaseModel


class RewardRequest(BaseModel):
    waste_types: list[str]
    weight_kg: float
    distance_km: float
    is_urgent: bool = False


class RewardResponse(BaseModel):
    base_fee_jd: float
    distance_fee_jd: float
    material_fee_jd: float
    urgency_bonus_jd: float
    vat_jd: float
    total_jd: float
    material_rate_used: float
