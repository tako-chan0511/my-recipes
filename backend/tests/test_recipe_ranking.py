# backend/tests/test_recipe_ranking.py

from fastapi.testclient import TestClient
from api.main import app

client = TestClient(app)

def test_recipe_ranking():
    response = client.get("/api/recipe-ranking?categoryId=30")
    assert response.status_code == 200
    data = response.json()

    assert isinstance(data, dict)
    assert "result" in data
    assert isinstance(data["result"], list)

    # 任意の項目でバリデーション（"title" ではなく "foodImageUrl" に変更）
    if data["result"]:  # 空でないときだけ検査
        assert all("foodImageUrl" in item for item in data["result"])
