import os
import asyncpg
from google.cloud.sql.connector import create_async_connector, IPTypes

_pool: asyncpg.Pool | None = None
_connector = None


async def get_pool() -> asyncpg.Pool:
    global _pool, _connector
    if _pool is None:
        _connector = await create_async_connector()

        async def _connect(*_args, **_kwargs) -> asyncpg.Connection:
            return await _connector.connect(
                os.environ["CLOUD_SQL_CONNECTION_NAME"],
                "asyncpg",
                user=os.environ.get("DB_USER", "postgres"),
                password=os.environ["DB_PASSWORD"],
                db=os.environ.get("DB_NAME", "dawer"),
                ip_type=IPTypes.PRIVATE,
            )

        _pool = await asyncpg.create_pool(
            connect=_connect,
            min_size=0,
            max_size=10,
            command_timeout=30,
        )
    return _pool


async def close_pool() -> None:
    global _pool, _connector
    if _pool:
        await _pool.close()
        _pool = None
    if _connector:
        await _connector.close_async()
        _connector = None
