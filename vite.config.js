import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
export default defineConfig({
    plugins: [vue()],
    root: '.', // プロジェクトルート（デフォルト）
    build: {
        outDir: 'dist', // ← distにビルド（このままでOK）
    },
    base: './', // ← Vercelで相対パス解決できるように
    server: {
        proxy: {
            // '/api'で始まるリクエストを、Vercelのローカルサーバー(通常はポート3000)に転送
            '/api': {
                target: 'http://localhost:8686',
                changeOrigin: true,
                // rewrite: (path) => path.replace(/^\/api/, '') // ←ここ追加！
            },
        },
    },
});
