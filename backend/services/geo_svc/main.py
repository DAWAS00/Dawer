from contextlib import asynccontextmanager
from typing import Annotated

from fastapi import Depends, FastAPI

from shared.db import close_pool, get_pool
from shared.errors import not_found_handler, unhandled_handler
from shared.firebase import verify_token

from .models import NearbyDriversRequest, NearbyDriversResponse, DriverSummary


@asynccontextmanager
async def lifespan(app: FastAPI):
    yield
    await close_pool()


app = FastAPI(title="geo-svc", version="1.0.0", lifespan=lifespan)
app.add_exception_handler(404, not_found_handler)
app.add_exception_handler(500, unhandled_handler)

TokenDep = Annotated[dict, Depends(verify_token)]


@app.post("/drivers/nearby", response_model=NearbyDriversResponse)
async def nearby_drivers(body: NearbyDriversRequest, token: TokenDep):
    pool = await get_pool()
    radius = min(body.radius_km or 15, 50)  # max 50km per spec

    rows = await pool.fetch(
        "SELECT * FROM nearby_drivers($1, $2, $3)",
        body.lat, body.lng, radius,
    )
    return {
        "drivers": [
            {
                "id": str(r["id"]),
                "name": r["name"],
                "fcm_token": r["fcm_token"],
                "distance_m": r["distance_m"],
            }
            for r in rows
        ],
        "radius_km": radius,
    }
