# 1. フロントエンドビルドステージ
FROM node:20 AS frontend
WORKDIR /frontend
COPY frontend/ ./
RUN npm install && npm run build

# 2. バックエンドステージ
FROM python:3.11-slim
WORKDIR /app

# Python依存関係インストール
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# バックエンドとビルド済みフロントを配置
COPY api/ /app/api/
COPY --from=frontend /frontend/dist/ /app/dist/

# アプリ起動
CMD uvicorn api.main:app --host 0.0.0.0 --port $PORT
