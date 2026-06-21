from fastapi import Request
from fastapi.responses import JSONResponse


def error_response(code: str, message: str, status_code: int) -> JSONResponse:
    return JSONResponse(
        status_code=status_code,
        content={"error": {"code": code, "message": message}},
    )


async def not_found_handler(request: Request, exc: Exception) -> JSONResponse:
    return error_response("NOT_FOUND", "Resource not found", 404)


async def unhandled_handler(request: Request, exc: Exception) -> JSONResponse:
    return error_response("INTERNAL_ERROR", "An unexpected error occurred", 500)
