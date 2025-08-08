# api/main.py

import os
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from dotenv import load_dotenv

# ルーターをインポート
from .get_categories import router as categories_router
from .recipe_ranking import router as ranking_router

# .envファイルから環境変数を読み込む
load_dotenv()

# FastAPIアプリケーションのインスタンスを作成
app = FastAPI()

# --- APIルートの設定 ---
# /api というパスで、各APIを有効にする
app.include_router(categories_router, prefix="/api")
app.include_router(ranking_router, prefix="/api")

# --- フロントエンドの配信設定 ---
# このコードが、FastAPIにVue.jsの静的ファイルを配信させるための設定
# "/app/dist" ディレクトリをルートURL("/")で公開する
# html=True は、/ や /about のようなパスへのアクセス時に index.html を返すSPA向けのオプション
app.mount("/", StaticFiles(directory="dist", html=True), name="static")