# tests/test_get_categories.py

from fastapi.testclient import TestClient
from api.main import app

client = TestClient(app)

def test_get_categories():
    response = client.get("/api/get-categories")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, dict)
    assert "large" in data
    assert isinstance(data["large"], list)
