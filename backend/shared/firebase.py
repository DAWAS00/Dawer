import json
import os
from functools import lru_cache

import firebase_admin
from firebase_admin import auth, credentials
from fastapi import Header, HTTPException, status
from google.cloud import secretmanager


@lru_cache(maxsize=1)
def _init_app() -> firebase_admin.App:
    project_id = os.environ.get("GCP_PROJECT", "dawer-prod")
    secret_name = f"projects/{project_id}/secrets/firebase-admin-sdk/versions/latest"

    client = secretmanager.SecretManagerServiceClient()
    response = client.access_secret_version(name=secret_name)
    sdk_json = json.loads(response.payload.data.decode())

    cred = credentials.Certificate(sdk_json)
    return firebase_admin.initialize_app(cred)


def _ensure_initialized() -> None:
    try:
        firebase_admin.get_app()
    except ValueError:
        _init_app()


async def verify_token(authorization: str = Header(...)) -> dict:
    """FastAPI dependency — verifies Firebase JWT, returns decoded token claims."""
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Missing Bearer token")

    token = authorization.removeprefix("Bearer ").strip()
    _ensure_initialized()

    try:
        decoded = auth.verify_id_token(token, check_revoked=True)
    except auth.RevokedIdTokenError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token revoked")
    except auth.InvalidIdTokenError as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=str(e))

    return decoded
