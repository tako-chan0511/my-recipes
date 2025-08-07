# frontend/Dockerfile (最終確定版)

# --- ビルドステージ ---
FROM node:20-alpine as build-stage
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# --- プロダクションステージ ---
FROM nginx:stable-alpine as production-stage
COPY --from-build-stage /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/templates/default.conf.template
EXPOSE 80

# ▼▼▼ このCMD命令を修正 ▼▼▼
CMD sh -c "envsubst < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"