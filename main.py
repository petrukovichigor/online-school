import webview

from src.api import Api
from src.db.connection import test_connection

if __name__ == "__main__":
    if test_connection():
        webview.create_window(
            title="Online School",
            url="src/ui/auth.html",
            js_api=Api(),
            fullscreen=True
        )

        webview.start(http_server=True)