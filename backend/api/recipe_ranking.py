# backend/api/recipe_ranking.py

import os
import httpx
from fastapi import APIRouter, HTTPException, Query

router = APIRouter()

@router.get("/ranking")  # ✅ URLをシンプルに変更
async def recipe_ranking(categoryId: str = Query(...)):
    app_id = os.getenv("RAKUTEN_APP_ID")
    if not app_id:
        raise HTTPException(status_code=500, detail="API認証情報が設定されていません。")

    url = (
        "https://app.rakuten.co.jp/services/api/Recipe/CategoryRanking/20170426"
        f"?format=json&applicationId={app_id}&categoryId={categoryId}"
    )

    async with httpx.AsyncClient() as client:
        response = await client.get(url)

    if response.status_code == 200:
        return response.json()
    else:
        raise HTTPException(status_code=response.status_code, detail=response.text)
