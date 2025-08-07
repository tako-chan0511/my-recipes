# my-recipes/frontend/Dockerfile

# --- ビルドステージ ---
FROM node:20-alpine as build-stage
# ... (ここは変更なし)
RUN npm run build

# --- プロダクションステージ ---
FROM nginx:stable-alpine as production-stage
COPY --from=build-stage /app/dist /usr/share/nginx/html
# ▼▼▼ この行を修正 ▼▼▼
COPY nginx.conf /etc/nginx/templates/default.conf.template
EXPOSE 80
# ▼▼▼ この行を修正/追記 ▼▼▼
CMD ["/bin/sh", "-c", "envsubst '${PROXY_PASS}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]