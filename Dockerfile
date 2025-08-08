# 1. ベースイメージとしてPython環境を選択
FROM python:3.11-slim

# 2. コンテナ内の作業ディレクトリを設定
WORKDIR /app

# 3. 依存関係をインストール
# まず requirements.txt だけをコピーして、先にインストールする
# これにより、Pythonコードの変更だけでは再インストールが走らず、ビルドが高速化される
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. backendディレクトリ全体をコンテナにコピー
# これには、api/ や、先ほど移動した dist/ も含まれる
COPY backend/ /app/

# 5. Renderが指定するポートでアプリケーションを起動
# ${PORT:-10000} は、RenderからのPORT指定があればそれに従い、なければ10000番ポートを使う設定
CMD ["sh", "-c", "uvicorn api.main:app --host 0.0.0.0 --port ${PORT:-10000}"]