from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_root_returns_ok_status():
    response = client.get("/")
    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "ok"
    assert "timestamp" in body


def test_health_endpoint():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_echo_returns_message_and_length():
    response = client.post("/echo", json={"message": "hello"})
    assert response.status_code == 200
    body = response.json()
    assert body["message"] == "hello"
    assert body["length"] == 5


def test_echo_rejects_missing_field():
    response = client.post("/echo", json={})
    assert response.status_code == 422
