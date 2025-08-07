# frontend/Dockerfile (最終確定版)

# --- ビルドステージ ---
FROM node:20-alpine as build-stage
WORKDIR /app

# ▼▼▼ パスから「frontend/」を削除 ▼▼▼
COPY package*.json ./
RUN npm install

# ▼▼▼ パスから「frontend/」を削除 ▼▼▼
COPY . .
RUN npm run build

# --- プロダクションステージ ---
FROM nginx:stable-alpine as production-stage
COPY --from=build-stage /app/dist /usr/share/nginx/html

# ▼▼▼ パスから「frontend/」を削除 ▼▼▼
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]