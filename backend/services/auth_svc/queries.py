import asyncpg
from .models import CreateProfileRequest, UpdateProfileRequest


async def db_get_user_by_firebase_uid(pool: asyncpg.Pool, uid: str) -> asyncpg.Record | None:
    return await pool.fetchrow("SELECT * FROM public.users WHERE firebase_uid = $1", uid)


async def db_create_user(
    pool: asyncpg.Pool, firebase_uid: str, phone: str, body: CreateProfileRequest
) -> asyncpg.Record:
    return await pool.fetchrow(
        """
        INSERT INTO public.users (firebase_uid, name, phone, role, supplier_type,
            vehicle_model, vehicle_color, vehicle_plate, vehicle_type, address)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
        RETURNING *
        """,
        firebase_uid, body.name, phone, body.role, body.supplier_type,
        body.vehicle_model, body.vehicle_color, body.vehicle_plate,
        body.vehicle_type, body.address,
    )


async def db_update_user(
    pool: asyncpg.Pool, user_id: str, body: UpdateProfileRequest
) -> asyncpg.Record:
    return await pool.fetchrow(
        """
        UPDATE public.users SET
            name              = COALESCE($2, name),
            address           = COALESCE($3, address),
            vehicle_model     = COALESCE($4, vehicle_model),
            vehicle_color     = COALESCE($5, vehicle_color),
            vehicle_plate     = COALESCE($6, vehicle_plate),
            vehicle_type      = COALESCE($7, vehicle_type),
            profile_photo_url = COALESCE($8, profile_photo_url),
            updated_at        = now()
        WHERE id = $1::uuid
        RETURNING *
        """,
        user_id, body.name, body.address, body.vehicle_model,
        body.vehicle_color, body.vehicle_plate, body.vehicle_type, body.profile_photo_url,
    )


async def db_update_fcm_token(pool: asyncpg.Pool, user_id: str, fcm_token: str) -> None:
    await pool.execute(
        "UPDATE public.users SET fcm_token = $2, updated_at = now() WHERE id = $1::uuid",
        user_id, fcm_token,
    )


async def db_toggle_availability(pool: asyncpg.Pool, user_id: str) -> None:
    await pool.execute(
        "UPDATE public.users SET is_available = NOT is_available, updated_at = now() WHERE id = $1::uuid",
        user_id,
    )
