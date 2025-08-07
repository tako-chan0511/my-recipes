#!/bin/sh

envsubst '${PROXY_PASS} ${RENDER_DNS_RESOLVER_IP}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

nginx -g 'daemon off;'