import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import { resolve } from 'path';
export default defineConfig({
    plugins: [vue()],
    root: '.',
    base: './',
    build: {
        // ✅ 出力先を backend/dist に変更
        outDir: resolve(__dirname, 'backend/dist'),
        emptyOutDir: true // 古いファイルをクリア
    },
    server: {
        host: '0.0.0.0',
        port: 5173,
        proxy: {
            '/api': {
                target: 'http://backend:8686',
                changeOrigin: true
            }
        }
    }
});
