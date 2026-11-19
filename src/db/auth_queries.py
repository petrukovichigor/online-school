from src.db.connection import query, tx

TABLES = {"student": ("students", "student_id"), "teacher": ("teachers", "teacher_id")}


def find_user(role, email):
    table, pk = TABLES[role]  # the table name comes only from the dict, never from user input
    rows = query(f"""
        SELECT {pk} AS id, first_name, last_name, email, password_hash
        FROM {table} WHERE email = %s
    """, (email,))
    return rows[0] if rows else None


def create_student(first_name, last_name, email, phone, password_hash):
    with tx() as cur:
        cur.execute("""
            INSERT INTO students (first_name, last_name, email, password_hash, phone_number)
            VALUES (%s, %s, %s, %s, %s) RETURNING student_id
        """, (first_name, last_name, email, password_hash, phone or None))
        return cur.fetchone()["student_id"]
