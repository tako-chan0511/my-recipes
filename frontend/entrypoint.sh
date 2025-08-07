#!/bin/sh

# PROXY_PASS(バックエンドURL)とRENDER_DNS_RESOLVER_IP(RenderのDNS)をNginx設定に埋め込む
envsubst '${PROXY_PASS} ${RENDER_DNS_RESOLVER_IP}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

# Nginxを起動
nginx -g 'daemon off;'