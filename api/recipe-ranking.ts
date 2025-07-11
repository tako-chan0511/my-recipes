import type { VercelRequest, VercelResponse } from '@vercel/node';

export default async function handler(
  req: VercelRequest,
  res: VercelResponse,
) {
  // 環境変数からIDを安全に取得
  const appId = process.env.RAKUTEN_APP_ID;
  // フロントエンドから送られてきたカテゴリIDを取得
  const categoryId = req.query.categoryId as string;

  if (!categoryId) {
    return res.status(400).json({ error: 'カテゴリが指定されていません。' });
  }
  if (!appId) {
    return res.status(500).json({ error: 'API認証情報がサーバー側で設定されていません。' });
  }

  const apiUrl = `https://app.rakuten.co.jp/services/api/Recipe/CategoryRanking/20170426?format=json&applicationId=${appId}&categoryId=${categoryId}`;

  try {
    const apiResponse = await fetch(apiUrl);
    const data = await apiResponse.json();

    if (apiResponse.ok) {
      res.status(200).json(data);
    } else {
      res.status(apiResponse.status).json(data);
    }
  } catch (error) {
    res.status(500).json({ error: 'サーバーでエラーが発生しました。' });
  }
}
