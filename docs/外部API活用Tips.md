# 目的
Vue 3 (フロントエンド) と Vercel Functions (サーバーレス・バックエンド) を組み合わせ、外部APIを安全に呼び出すWebアプリケーションを構築し、Vercel上で公開するまでの手順をまとめる。

## 最終的なフォルダ構成
```
my-app/
├── api/
│   └── [function-name].ts  // バックエンドのAPIコード (例: recipe-ranking.ts)
├── node_modules/
├── public/
├── src/
│   ├── components/
│   └── App.vue             // フロントエンドのUIコード
├── .env.local              // 【重要】ローカル開発用の環境変数（APIキーなど）
├── .gitignore
├── index.html
├── package.json
├── tsconfig.json           // 【重要】プロジェクト全体のTypeScript設定
├── tsconfig.node.json      // 【重要】Node.js環境用のTypeScript設定
├── vercel.json             // 【重要】Vercelの本番環境用設定
└── vite.config.ts          // 【重要】Vite（ローカル開発サーバー）の設定
```

## 主要な設定ファイルとその役割

### 1. vite.config.ts (ローカル開発サーバーの設定)
ローカル開発中に、フロントエンドからバックエンドへのAPIリクエストを正しく転送するための「代理人（プロキシ）」を設定します。

役割: localhost:5173 (フロントエンド) から /api/ へのアクセスを、localhost:3000 (Vercelのローカルバックエンド) に中継する。これにより、開発環境でのCORS問題を回避。

コマンド: `vercel dev` で起動した際に使われます。

```js
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    proxy: {
      // '/api'で始まるリクエストを、Vercelのローカルサーバーに転送
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true,
      },
    },
  },
})
```

### 2. vercel.json (Vercel本番環境の設定)
本番環境で、フロントエンドからバックエンドへのAPIリクエストを正しく転送するための「書き換えルール」を設定します。

役割: 公開されたURL (*.vercel.app) 上で、/api/ へのアクセスを、Vercel Functionsのバックエンドコードに内部的に繋ぎこむ。

コマンド: `git push` でデプロイされた本番環境で使われます。

```json
{
  "rewrites": [
    {
      "source": "/api/:path*",
      "destination": "/api/:path*"
    }
  ]
}
```

### 3. .env.local (ローカル開発用のAPIキー)
ローカル開発中に、バックエンドコードが使用するAPIキーなどの秘密情報を記述します。

役割: `vercel dev` で起動した際に、`process.env.変数名` の形でバックエンドに読み込まれます。

注意: このファイルは.gitignoreに必ず含め、Gitで公開しないようにします。

例:
```
# .env.local の記述例
# バックエンド(Vercel Functions)でのみ使う変数は、接頭辞なし
RAKUTEN_APP_ID="YOUR_API_KEY_HERE"

# フロントエンド(Vue)でも使いたい変数は、VITE_という接頭辞を付ける
VITE_APP_TITLE="My Awesome App"
```

### 4. tsconfig.json (プロジェクト全体のTypeScript設定)
プロジェクト全体のTypeScriptのルールを定義します。フロントエンドとバックエンドの両方のコードをチェック対象に含めることが重要です。

```json
{
  "compilerOptions": {
    "target": "ESNext",
    "useDefineForClassFields": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "jsx": "preserve",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "esModuleInterop": true,
    "lib": ["ESNext", "DOM"],
    "skipLibCheck": true,
    "noEmit": true,
    "paths": {
      "@/*": ["./src/*"]
    },
    "types": ["vite/client", "node"]
  },
  // srcフォルダとapiフォルダの両方をチェック対象に含める
  "include": ["src/**/*.ts", "src/**/*.d.ts", "src/**/*.tsx", "src/**/*.vue", "api/**/*.ts"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

### 5. tsconfig.node.json (Node.js環境用のTypeScript設定)
vite.config.ts のような、Node.js環境で実行される設定ファイル自体のためのTypeScriptルールを定義します。

```json
{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true
  },
  "include": ["vite.config.ts"]
}
```

## 開発から公開までの流れ

1. APIキー取得: 利用したい外部サービスのAPIキーを取得する。
2. プロジェクト作成: `npm create vite@latest` でVue+TSプロジェクトを作成。
3. Vercel連携:
    - `npm i -g vercel` でVercel CLIをインストール。
    - `vercel login` でログイン。
    - `vercel link` でGitリポジトリとVercelプロジェクトを連携させる。
4. 環境変数設定:
    - 本番用: `vercel env add VAR_NAME` でVercelのサーバーにAPIキーを登録。
    - 開発用: `vercel pull` で本番用の設定をローカルに同期し、.env.local にも念のため記述しておく。
5. ローカル開発: `vercel dev` コマンドでフロントエンドとバックエンドを同時に起動して開発を進める。
6. 本番公開:
    - `git add .`
    - `git commit -m "コミットメッセージ"`
    - `git push origin main`
    - pushをきっかけに、Vercelが自動でデプロイを実行する。

---

この手順書が、今後の開発の素晴らしいテンプレートとなることを願っています！