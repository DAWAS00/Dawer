from pydantic import BaseModel


class NearbyDriversRequest(BaseModel):
    lat: float
    lng: float
    radius_km: float | None = 15


class DriverSummary(BaseModel):
    id: str
    name: str
    fcm_token: str | None
    distance_m: float


class NearbyDriversResponse(BaseModel):
    drivers: list[DriverSummary]
    radius_km: float
