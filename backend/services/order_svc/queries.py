import asyncpg
from .models import CreateOrderRequest


async def db_get_user_by_firebase_uid(pool: asyncpg.Pool, uid: str) -> asyncpg.Record | None:
    return await pool.fetchrow(
        "SELECT id, role, is_verified FROM public.users WHERE firebase_uid = $1", uid
    )


async def db_create_order(
    pool: asyncpg.Pool,
    body: CreateOrderRequest,
    creator_id: str,
    creator_role: str,
) -> asyncpg.Record:
    supplier_id = creator_id if creator_role in ("supplier", "individual", "storeBusiness") else None
    company_id = creator_id if creator_role == "recyclingCo" else None

    return await pool.fetchrow(
        """
        INSERT INTO public.orders (
            type, waste_types, waste_form, weight_category, pickup_target,
            pickup_location, estimated_weight_kg, distance_km, reward_jd,
            is_urgent, notes, is_marketplace_shared, requires_rider,
            required_vehicle_type, requires_chemical_permit,
            job_description, payment_model, price_per_kg, item_price,
            min_quantity_kg, collection_delivery_method,
            supplier_id, company_id
        ) VALUES (
            $1, $2, $3, $4, $5,
            ST_MakePoint($7, $6)::GEOGRAPHY, $8, $9, $10,
            $11, $12, $13, $14,
            $15, $16,
            $17, $18, $19, $20,
            $21, $22,
            $23, $24
        )
        RETURNING *
        """,
        body.type, body.waste_types, body.waste_form, body.weight_category, body.pickup_target,
        body.pickup_lat, body.pickup_lng, body.estimated_weight_kg, body.distance_km, body.reward_jd,
        body.is_urgent, body.notes, body.is_marketplace_shared, body.requires_rider,
        body.required_vehicle_type, body.requires_chemical_permit,
        body.job_description, body.payment_model, body.price_per_kg, body.item_price,
        body.min_quantity_kg, body.collection_delivery_method,
        supplier_id, company_id,
    )


async def db_get_order(pool: asyncpg.Pool, order_id: str) -> asyncpg.Record | None:
    return await pool.fetchrow("SELECT * FROM public.orders WHERE id = $1::uuid", order_id)


async def db_list_orders(
    pool: asyncpg.Pool,
    user_id: str,
    user_role: str,
    filter_status: str | None,
    page: int,
    page_size: int,
) -> tuple[list[asyncpg.Record], int]:
    offset = (page - 1) * page_size
    conditions = []
    args: list = []

    if user_role == "driver":
        conditions.append(f"(driver_id = ${len(args)+1}::uuid OR status = 'pending')")
        args.append(user_id)
    elif user_role == "recyclingCo":
        conditions.append(f"company_id = ${len(args)+1}::uuid")
        args.append(user_id)
    else:
        conditions.append(f"supplier_id = ${len(args)+1}::uuid")
        args.append(user_id)

    if filter_status:
        conditions.append(f"status = ${len(args)+1}")
        args.append(filter_status)

    where = "WHERE " + " AND ".join(conditions) if conditions else ""

    total = await pool.fetchval(f"SELECT COUNT(*) FROM public.orders {where}", *args)
    rows = await pool.fetch(
        f"SELECT * FROM public.orders {where} ORDER BY created_at DESC LIMIT ${ len(args)+1 } OFFSET ${ len(args)+2 }",
        *args, page_size, offset,
    )
    return rows, total


async def db_patch_order_status(
    pool: asyncpg.Pool,
    order_id: str,
    new_status: str,
    driver_id: str | None,
    proof_photo_url: str | None,
) -> asyncpg.Record:
    return await pool.fetchrow(
        """
        UPDATE public.orders
        SET status = $2,
            driver_id = COALESCE($3::uuid, driver_id),
            proof_photo_url = COALESCE($4, proof_photo_url),
            updated_at = now()
        WHERE id = $1::uuid
        RETURNING *
        """,
        order_id, new_status, driver_id, proof_photo_url,
    )
