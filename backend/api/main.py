# backend/api/main.py

import os
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from dotenv import load_dotenv
from pathlib import Path

# ルーターをインポート
from .get_categories import router as categories_router
from .recipe_ranking import router as ranking_router

def create_app(mount_static_files: bool = True) -> FastAPI:
    """
    FastAPIアプリケーションのインスタンスを作成して返すファクトリ関数。
    """
    # .envファイルから環境変数を読み込む
    load_dotenv()

    # FastAPIアプリケーションのインスタンスを作成
    app = FastAPI()

    # --- APIルートの設定 ---
    app.include_router(categories_router, prefix="/api")
    app.include_router(ranking_router, prefix="/api")

    # --- フロントエンドの配信設定 ---
    # mount_static_filesフラグがTrueの場合のみ、静的ファイルをマウントする
    if mount_static_files:
        dist_path = Path(__file__).parent.parent / "dist"
        if dist_path.exists():
            app.mount("/", StaticFiles(directory=dist_path, html=True), name="static")

    return app

# Uvicornがこのファイルを実行したときに、デフォルトで本番用のアプリを作成する
app = create_app()
