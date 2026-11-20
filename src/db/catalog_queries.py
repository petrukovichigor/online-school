from src.db.connection import num, query


def categories():
    return [r["name"] for r in query("SELECT name FROM categories ORDER BY name")]


def courses():
    rows = query("""
        SELECT c.course_id AS id, c.title, c.description, c.price,
               cat.name AS category,
               t.first_name || ' ' || t.last_name AS teacher
        FROM courses c
        JOIN categories cat ON cat.category_id = c.category_id
        JOIN teachers t     ON t.teacher_id = c.teacher_id
        ORDER BY c.title
    """)
    return num(rows, "price")  # DECIMAL cannot be passed to JS as is
