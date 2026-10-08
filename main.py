import sys
from src.db.connection import test_connection

def main():
    print("Запуск приложения Online School...")

    # 1. Проверяем базу данных
    if not test_connection():
        print("Приложение остановлено из-за ошибки подключения к БД.")
        sys.exit(1)

    # 2. Если всё ок, дальше пойдет запуск вашего GUI
    print("Инициализация интерфейса...")
    # Здесь позже импортируете и вызовете окно авторизации:
    # from src.ui.auth_window import AuthWindow
    # app = AuthWindow()
    # app.mainloop()


if __name__ == "__main__":
    main()
