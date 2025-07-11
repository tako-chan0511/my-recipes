import type { VercelRequest, VercelResponse } from '@vercel/node';

export default async function handler(
  req: VercelRequest,
  res: VercelResponse,
) {
  // 環境変数からIDを安全に取得
  const appId = process.env.RAKUTEN_APP_ID;
  // フロントエンドから送られてきたカテゴリIDを取得
  const categoryId = req.query.categoryId as string;

  // デバッグ用に、受け取った情報をターミナルに出力
  console.log(`[API] Received request for categoryId: ${categoryId}`);

  if (!categoryId) {
    console.error('[API] Error: カテゴリIDが指定されていません。');
    return res.status(400).json({ error: 'カテゴリが指定されていません。' });
  }
  if (!appId) {
    console.error('[API] Error: API認証情報がサーバー側で設定されていません。');
    return res.status(500).json({ error: 'API認証情報がサーバー側で設定されていません。' });
  }

  const apiUrl = `https://app.rakuten.co.jp/services/api/Recipe/CategoryRanking/20170426?format=json&applicationId=${appId}&categoryId=${categoryId}`;
  console.log(`[API] Fetching URL: ${apiUrl}`);

  try {
    const apiResponse = await fetch(apiUrl);
    const responseText = await apiResponse.text(); // まずテキストとして応答を取得
    console.log(`[API] Received response status: ${apiResponse.status}`);
    console.log(`[API] Received response body: ${responseText}`);

    // 応答がJSONでない場合（HTMLのエラーページなど）を考慮
    let data;
    try {
      data = JSON.parse(responseText);
    } catch (parseError) {
      console.error('[API] Error: JSONのパースに失敗しました。', parseError);
      return res.status(500).json({ error: 'APIからの応答が不正な形式です。', body: responseText });
    }

    if (apiResponse.ok) {
      res.status(200).json(data);
    } else {
      res.status(apiResponse.status).json(data);
    }
  } catch (error) {
    console.error('[API] Error: fetch中にエラーが発生しました。', error);
    res.status(500).json({ error: 'サーバーでエラーが発生しました。' });
  }
}
