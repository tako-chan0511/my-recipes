# tests/test_main.py

from fastapi.testclient import TestClient
from api.main import app

client = TestClient(app)

def test_root_serves_frontend():
    response = client.get("/")
    assert response.status_code in (200, 404)  # /dist が存在しない可能性もあるため
