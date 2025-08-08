# 1. ベースイメージとしてPython環境を選択
FROM python:3.11-slim

# 2. コンテナ内の作業ディレクトリを設定
WORKDIR /app

# 3. 依存関係をインストール
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. backendディレクトリ全体をコンテナにコピー
COPY backend/ /app/

# --- ここからが診断用コマンド ---
# コピー後の/appディレクトリの中身を全てリスト形式で表示して、ログに出力します
# これで、distフォルダが本当に存在するか、中身がどうなっているかを確認します
RUN ls -laR /app
# --- 診断用コマンドここまで ---

# 5. Renderが指定するポートでアプリケーションを起動
CMD ["sh", "-c", "uvicorn api.main:app --host 0.0.0.0 --port ${PORT:-10000}"]