# backend/Dockerfile (最終確定版)

# Pythonの公式イメージをベースにする
FROM python:3.11-slim

# 作業ディレクトリを設定
WORKDIR /app

# 依存関係ファイルをコピーしてインストール
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# アプリケーションコードをコピー
COPY api/ ./api/

# ポート8686を公開
EXPOSE 8686

# コンテナ起動時に実行するコマンド
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8686"]