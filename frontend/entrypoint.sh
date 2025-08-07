#!/bin/sh

# バックエンドの準備ができるまで待つ
echo "Waiting for backend to be ready..."
while ! curl -s "http://my-recipes-backend:8686/docs" > /dev/null; do
  echo "Backend not ready yet, waiting 5 seconds..."
  sleep 5
done
echo "Backend is ready!"

# バックエンドの準備ができたので、Nginxの設定を生成して起動する
echo "Starting Nginx..."
envsubst '${PROXY_PASS}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf
nginx -g 'daemon off;'