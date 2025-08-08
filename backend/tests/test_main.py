# backend/tests/test_main.py

from fastapi.testclient import TestClient
# FastAPIインスタンスではなく、create_app関数をインポートする
from api.main import create_app 

# テスト専用のアプリを作成（静的ファイルはマウントしない）
app = create_app(mount_static_files=False)

# TestClientにテスト用アプリを渡す
client = TestClient(app)

def test_read_main_is_not_found():
    """
    静的ファイルがマウントされていないため、ルートパスは404を返すはず
    """
    response = client.get("/")
    assert response.status_code == 404

# ... (他のAPIテストは変更なし)
