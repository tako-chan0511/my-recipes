# backend/api/main.py

import os
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from dotenv import load_dotenv
from pathlib import Path # pathlibをインポート

# ルーターをインポート
from .get_categories import router as categories_router
from .recipe_ranking import router as ranking_router

# .envファイルから環境変数を読み込む
load_dotenv()

# FastAPIアプリケーションのインスタンスを作成
app = FastAPI()

# --- APIルートの設定 ---
app.include_router(categories_router, prefix="/api")
app.include_router(ranking_router, prefix="/api")


# --- フロントエンドの配信設定 ---
# ↓↓↓ この部分を、より確実なパスの指定方法に変更します ↓↓↓

# このファイルの場所を基準に、distディレクトリの絶対パスを構築
# これにより、どこから実行されてもパスがずれることがなくなる
dist_path = Path(__file__).parent.parent / "dist"

# 静的ファイルの配信設定
if dist_path.exists():
    app.mount("/", StaticFiles(directory=dist_path, html=True), name="static")
else:
    print(f"Warning: Static file directory not found at {dist_path}")