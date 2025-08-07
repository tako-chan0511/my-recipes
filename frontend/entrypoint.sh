#!/bin/sh

# 環境変数をnginx.conf.templateに適用して、新しい設定ファイルを生成
envsubst < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

# Nginxを起動
nginx -g 'daemon off;'