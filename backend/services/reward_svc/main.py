from typing import Annotated
from fastapi import Depends, FastAPI
from shared.firebase import verify_token
from shared.errors import not_found_handler, unhandled_handler
from .models import RewardRequest, RewardResponse

app = FastAPI(title="reward-svc", version="1.0.0")
app.add_exception_handler(404, not_found_handler)
app.add_exception_handler(500, unhandled_handler)

TokenDep = Annotated[dict, Depends(verify_token)]

MATERIAL_RATES = {
    "oil":         0.05,
    "plastic":     0.03,
    "metal":       0.07,
    "glass":       0.02,
    "electronics": 0.10,
    "organic":     0.01,
    "paper":       0.02,
    "textile":     0.02,
    "wood":        0.02,
    "rubber":      0.03,
    "chemicals":   0.08,
    "batteries":   0.09,
    "furniture":   0.02,
    "tires":       0.04,
    "construction":0.03,
    "copperAluminium": 0.12,
}

BASE_FEE = 1.50
DISTANCE_RATE = 0.60
URGENCY_BONUS = 0.50
VAT_RATE = 0.16


@app.post("/rewards/calculate", response_model=RewardResponse)
async def calculate_reward(body: RewardRequest, token: TokenDep):
    material_rate = max(MATERIAL_RATES.get(wt, 0.02) for wt in body.waste_types) if body.waste_types else 0.02

    base_fee      = BASE_FEE
    distance_fee  = round(body.distance_km * DISTANCE_RATE, 3)
    material_fee  = round(body.weight_kg * material_rate, 3)
    urgency_bonus = URGENCY_BONUS if body.is_urgent else 0.0
    gross         = round(base_fee + distance_fee + material_fee + urgency_bonus, 3)
    vat           = round(gross * VAT_RATE, 3)
    total         = round(gross + vat, 3)

    return {
        "base_fee_jd":      base_fee,
        "distance_fee_jd":  distance_fee,
        "material_fee_jd":  material_fee,
        "urgency_bonus_jd": urgency_bonus,
        "vat_jd":           vat,
        "total_jd":         total,
        "material_rate_used": material_rate,
    }
