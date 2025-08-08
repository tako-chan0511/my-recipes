# --- ステージ1: フロントエンドのビルド ---
FROM node:20 AS frontend-builder
WORKDIR /app
COPY frontend/ ./frontend/
WORKDIR /app/frontend
RUN npm install && npm run build

# --- ステージ2: 最終的なアプリケーションの構築 ---
FROM python:3.11-slim
WORKDIR /app

# バックエンドのコードをコピー
COPY backend/ ./backend/

# ステージ1でビルドしたフロントエンドの成果物をコピー
COPY --from=frontend-builder /app/backend/dist ./backend/dist/

# 依存関係をインストール
RUN pip install --no-cache-dir -r backend/requirements.txt

# ↓↓↓ これが、全てを解決する最後の1行です ↓↓↓
# backendディレクトリを作業場所として指定する
WORKDIR /app/backend

# 最終的な実行コマンド
# これで、uvicornは正しい場所からapi.mainを探しに行ける
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8686"]
