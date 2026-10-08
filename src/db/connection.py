import psycopg2
import src.config as config

def get_db_connection():
    try:
        connection = psycopg2.connect(
            host=config.DB_HOST,
            port=config.DB_PORT,
            database=config.DB_NAME,
            user=config.DB_USER,
            password=config.DB_PASSWORD
        )
        return connection
    except Exception as error:
        print(f"Ошибка подключения: {error}")
        raise error

def test_connection():
    """Проверяет, работает ли подключение к базе данных."""
    try:
        conn = get_db_connection()
        with conn.cursor() as cur:
            # Делаем простейший тестовый запрос
            cur.execute("SELECT version();")
            db_version = cur.fetchone()
            print("=== [DB] Подключение успешно установлено! ===")
            print(f"=== [DB] Версия сервера: {db_version[0]}")
        conn.close()
        return True
    except Exception as e:
        print("=== [DB] КРИТИЧЕСКАЯ ОШИБКА ПОДКЛЮЧЕНИЯ! ===")
        print(f"=== [DB] Ошибка: {e}")
        return False