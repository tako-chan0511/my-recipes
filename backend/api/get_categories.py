import os
import httpx
from fastapi import APIRouter, HTTPException

router = APIRouter()

@router.get("/categories")  # ✅ REST風にURL変更
async def get_categories():
    try:
        app_id = os.getenv("RAKUTEN_APP_ID")
        if not app_id:
            raise RuntimeError("環境変数 RAKUTEN_APP_ID が設定されていません。")

        url = f"https://app.rakuten.co.jp/services/api/Recipe/CategoryList/20170426?format=json&applicationId={app_id}"

        async with httpx.AsyncClient() as client:
            response = await client.get(url)
            response.raise_for_status()
            data = response.json()

        return {
            "large": data["result"]["large"],
            "medium": data["result"]["medium"]
        }

    except Exception as e:
        print(f"❌ get_categories() 例外発生: {e}")
        raise HTTPException(status_code=500, detail=str(e))
