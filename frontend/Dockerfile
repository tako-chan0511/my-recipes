# --- ビルドステージ ---
FROM node:20-alpine as build-stage
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
# buildスクリプトを実行
RUN npm run build

# --- プロダクションステージ ---
FROM nginx:stable-alpine as production-stage
# ビルド成果物をNginxの公開ディレクトリにコピー
COPY --from=build-stage /app/dist /usr/share/nginx/html
# Nginxの設定ファイルをコピー
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]