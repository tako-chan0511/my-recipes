#!/bin/sh

# バックエンドの準備が完全に整うまで待つ
echo "Waiting for backend to be ready with a 200 OK..."
until [ "$(curl -s -o /dev/null -w '%{http_code}' http://my-recipes-backend:8686/docs)" = "200" ]; do
  echo "Backend not ready yet (not 200 OK), waiting 5 seconds..."
  sleep 5
done
echo "Backend is ready with 200 OK!"

# バックエンドの準備ができたので、Nginxの設定を生成して起動する
echo "Starting Nginx..."
envsubst '${PROXY_PASS}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf
nginx -g 'daemon off;'