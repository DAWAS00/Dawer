import os
from google.cloud import firestore

_client: firestore.AsyncClient | None = None


def _get_client() -> firestore.AsyncClient:
    global _client
    if _client is None:
        _client = firestore.AsyncClient(project=os.environ.get("GCP_PROJECT", "dawer-prod"))
    return _client


async def mirror_order(order_id: str, order_data: dict) -> None:
    """Mirror order status fields to Firestore for Flutter realtime listeners.
    Write failures are logged but do NOT rollback the Cloud SQL transaction.
    """
    client = _get_client()
    doc_ref = client.collection("orders").document(order_id)

    mirror_fields = {
        "id": order_data.get("id"),
        "status": order_data.get("status"),
        "supplier_id": order_data.get("supplier_id"),
        "driver_id": order_data.get("driver_id"),
        "company_id": order_data.get("company_id"),
        "waste_types": order_data.get("waste_types", []),
        "reward_jd": order_data.get("reward_jd"),
        "pickup_location": order_data.get("pickup_location"),
        "is_urgent": order_data.get("is_urgent"),
        "accepted_at": order_data.get("accepted_at"),
        "in_transit_at": order_data.get("in_transit_at"),
        "completed_at": order_data.get("completed_at"),
        "updated_at": order_data.get("updated_at"),
    }

    await doc_ref.set(mirror_fields, merge=True)
