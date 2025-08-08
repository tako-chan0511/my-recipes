# === フロントエンドビルド ===
FROM node:20 AS frontend
WORKDIR /app
COPY frontend/ ./frontend/
WORKDIR /app/frontend
RUN npm install && npm run build

# === バックエンドと統合 ===
FROM python:3.11-slim
WORKDIR /app

# Python依存関係
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# バックエンド（api）と dist を配置
COPY backend/api/ ./api/
COPY --from=frontend /app/frontend/dist/ ./dist/

# FastAPI起動
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "$PORT"]
