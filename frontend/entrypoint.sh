#!/bin/sh

echo "Waiting for backend to be ready with a 200 OK... Starting diagnostic mode."

# バックエンドからのHTTPステータスコードを取得
STATUS_CODE=$(curl -s -o /dev/null -w '%{http_code}' http://my-recipes-backend:8686/docs)

# ステータスコードが200になるまでループ
until [ "$STATUS_CODE" = "200" ]; do
  # ★★★★★ ここで、実際に受け取ったコードを表示します ★★★★★
  echo "Backend not ready. Current status code is [${STATUS_CODE}]. Waiting 5 seconds..."
  sleep 5
  # 再度ステータスコードを取得
  STATUS_CODE=$(curl -s -o /dev/null -w '%{http_code}' http://my-recipes-backend:8686/docs)
done

echo "Backend is ready with 200 OK!"
echo "Starting Nginx..."
envsubst '${PROXY_PASS}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf
nginx -g 'daemon off;'