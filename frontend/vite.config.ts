import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
  plugins: [vue()],
  root: '.', 
  base: './',
  build: {
    outDir: 'dist'
  },
  server: {
    // 変更点１：コンテナ外からのアクセスを許可
    host: '0.0.0.0', 
    port: 5173, // ポートも明記しておくと分かりやすい
    proxy: {
      '/api': {
        // 変更点２：ターゲットをDockerサービス名に変更
        target: 'http://backend:8686',
        changeOrigin: true
      }
    }
  }
});