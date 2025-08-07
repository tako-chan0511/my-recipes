# backend/Dockerfile

# Pythonの公式イメージをベースにする
FROM python:3.11-slim

# 作業ディレクトリを設定
WORKDIR /app

# 依存関係ファイルをコピーしてインストール
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# --- ▼▼▼ ここから下が変更点 ▼▼▼ ---

# アプリケーションコードをコピー (backendディレクトリの中身を全てコピー)
COPY . .

# ポート8686を公開
EXPOSE 8686

# コンテナ起動時に実行するコマンド (main.pyを直接指定)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8686"]