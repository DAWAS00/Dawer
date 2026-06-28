import json
import os

from google.cloud import pubsub_v1

_publisher: pubsub_v1.PublisherClient | None = None


def _get_publisher() -> pubsub_v1.PublisherClient:
    global _publisher
    if _publisher is None:
        _publisher = pubsub_v1.PublisherClient()
    return _publisher


def publish_order_event(order_id: str, status: str, order_data: dict) -> None:
    """Publish an order status change to the order-events Pub/Sub topic."""
    project_id = os.environ.get("GCP_PROJECT", "dawer-prod")
    topic_path = f"projects/{project_id}/topics/order-events"

    payload = json.dumps({
        "order_id": order_id,
        "status": status,
        "order": order_data,
    }).encode()

    publisher = _get_publisher()
    future = publisher.publish(topic_path, payload, order_id=order_id, status=status)
    future.result(timeout=10)
