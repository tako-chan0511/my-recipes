import type { VercelRequest, VercelResponse } from '@vercel/node';

export default async function handler(
  req: VercelRequest,
  res: VercelResponse,
) {
  // 環境変数からIDを安全に取得
  const appId = process.env.RAKUTEN_APP_ID;

  if (!appId) {
    return res.status(500).json({ error: 'API認証情報がサーバー側で設定されていません。' });
  }

  const apiUrl = `https://app.rakuten.co.jp/services/api/Recipe/CategoryList/20170426?format=json&applicationId=${appId}`;

  try {
    const apiResponse = await fetch(apiUrl);
    const data = await apiResponse.json();

    if (apiResponse.ok) {
      // 必要なカテゴリ情報だけを整形して返す
      const categories = {
        large: data.result.large,
        medium: data.result.medium,
      };
      res.status(200).json(categories);
    } else {
      res.status(apiResponse.status).json(data);
    }
  } catch (error) {
    res.status(500).json({ error: 'サーバーでエラーが発生しました。' });
  }
}
