#!/bin/sh

# DockerのDNSリゾルバを取得
RESOLVER=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')

# 環境変数をnginx.conf.templateに適用して、新しい設定ファイルを生成
# DockerのDNSをresolverとして設定
envsubst '${PROXY_PASS} ${RESOLVER}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

# Nginxを起動
nginx -g 'daemon off;'