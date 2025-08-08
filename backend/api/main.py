# backend/api/main.py

import os
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from dotenv import load_dotenv
from pathlib import Path

# ルーターをインポート
from .get_categories import router as categories_router
from .recipe_ranking import router as ranking_router

# .envファイルから環境変数を読み込む
load_dotenv()

# FastAPIアプリケーションのインスタンスを作成
app = FastAPI()

# --- APIルートの設定 ---
# (これは変更なし)
app.include_router(categories_router, prefix="/api")
app.include_router(ranking_router, prefix="/api")


# --- フロントエンドの配信設定 ---
# ↓↓↓ この部分を、より確実なパスの指定方法に修正します ↓↓↓

# このmain.pyファイルがある場所を基準点とする
current_file_path = Path(__file__).parent

# この基準点から、distディレクトリへの相対パスを構築する
# (../../dist と同じ意味)
dist_path = current_file_path.parent.parent / "dist"

# 静的ファイル配信のマウント
# 必ず、APIルートの後に記述する
app.mount("/", StaticFiles(directory=dist_path, html=True), name="static")