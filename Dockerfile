# === フロントエンドビルドステージ ===
FROM node:20 AS frontend
WORKDIR /app
COPY frontend/ ./frontend/
WORKDIR /app/frontend
RUN npm install && npm run build

# === バックエンド + dist 配信ステージ ===
FROM python:3.11-slim
WORKDIR /app

# Python依存関係
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# バックエンドとフロントエンドの配置
COPY api/ ./api/
COPY --from=frontend /app/frontend/dist/ ./dist/

# FastAPI 起動
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "$PORT"]
