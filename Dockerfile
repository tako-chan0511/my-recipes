# --- ステージ1: フロントエンドのビルド ---
FROM node:20 AS frontend-builder
WORKDIR /app
# frontendのソースコードだけをコピー
COPY frontend/ ./frontend/
# frontendディレクトリに移動してビルドを実行
WORKDIR /app/frontend
RUN npm install && npm run build
# この時点で、ビルド成果物は /app/backend/dist に生成される

# --- ステージ2: 最終的なアプリケーションの構築 ---
FROM python:3.11-slim
WORKDIR /app

# まず、バックエンドのコードをコピー
COPY backend/ ./backend/

# 次に、ステージ1でビルドしたフロントエンドの成果物を、正しい場所からコピーする
# これが今回の修正の核心
COPY --from=frontend-builder /app/backend/dist ./backend/dist/

# 依存関係をインストール
RUN pip install --no-cache-dir -r backend/requirements.txt

# 最終的な実行コマンド
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8686"]