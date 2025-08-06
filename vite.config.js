import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
export default defineConfig({
    plugins: [vue()],
    root: '.', // プロジェクトルート
    base: './', // Vercelで静的相対パスで配信するため
    build: {
        outDir: 'dist'
    },
    server: {
        proxy: {
            '/api': {
                target: 'http://localhost:8686',
                changeOrigin: true
                // rewrite: (path) => path.replace(/^\/api/, '') // ← prefix=/api をFastAPI側で吸収してるので不要
            }
        }
    }
});
