import psycopg2.errors

from src.db.connection import num, query, tx


def courses(teacher_id):
    rows = query("""
        SELECT c.course_id AS id, c.title, c.description, c.price, cat.name AS category,
               COUNT(s.subscr_id) FILTER (WHERE s.status = 'active') AS students,
               COALESCE(SUM(p.amount) FILTER (WHERE p.status = 'paid'), 0) AS revenue
        FROM courses c
        JOIN categories cat ON cat.category_id = c.category_id
        LEFT JOIN course_subscriptions s ON s.course_id = c.course_id
        LEFT JOIN payments p ON p.subscr_id = s.subscr_id
        WHERE c.teacher_id = %s
        GROUP BY c.course_id, cat.name
        ORDER BY c.title
    """, (teacher_id,))
    return num(rows, "price", "revenue")


def create_course(teacher_id, title, category, price, description):
    try:
        with tx() as cur:
            cur.execute("""
                INSERT INTO courses (title, description, price, category_id, teacher_id)
                SELECT %s, %s, %s, category_id, %s FROM categories WHERE name = %s
                RETURNING course_id
            """, (title, description or None, price, teacher_id, category))
            return cur.fetchone() is not None
    except psycopg2.errors.UniqueViolation:  # a course with this title already exists
        return False


def students(teacher_id, course_id):
    return query("""
        SELECT st.first_name || ' ' || st.last_name AS name, st.email, s.status
        FROM course_subscriptions s
        JOIN students st ON st.student_id = s.student_id
        JOIN courses c   ON c.course_id = s.course_id
        WHERE s.course_id = %s AND c.teacher_id = %s
        ORDER BY st.last_name, st.first_name
    """, (course_id, teacher_id))


def lessons(teacher_id, course_id):
    ls = query("""
        SELECT l.lesson_id AS id, l.position, l.title, l.video_url
        FROM lessons l JOIN courses c ON c.course_id = l.course_id
        WHERE l.course_id = %s AND c.teacher_id = %s
        ORDER BY l.position
    """, (course_id, teacher_id))
    hws = query("""
        SELECT homework_id AS id, lesson_id, description FROM homeworks
        WHERE lesson_id = ANY(%s) ORDER BY homework_id
    """, ([l["id"] for l in ls],)) if ls else []
    for l in ls:
        l["hws"] = [{"id": h["id"], "description": h["description"]} for h in hws if h["lesson_id"] == l["id"]]
    return ls


def add_lesson(teacher_id, course_id, position, title, video_url):
    try:
        with tx() as cur:
            cur.execute("""
                INSERT INTO lessons (course_id, position, title, video_url)
                SELECT c.course_id, %s, %s, %s FROM courses c
                WHERE c.course_id = %s AND c.teacher_id = %s
            """, (position, title, video_url, course_id, teacher_id))
            return cur.rowcount == 1
    except psycopg2.errors.UniqueViolation:  # this position is already taken
        return False


def delete_lesson(teacher_id, course_id, lesson_id):
    """Deletes the lesson, its assignments and submitted work (submissions reference assignments via RESTRICT)."""
    with tx() as cur:
        cur.execute("""
            SELECT 1 FROM lessons l JOIN courses c ON c.course_id = l.course_id
            WHERE l.lesson_id = %s AND l.course_id = %s AND c.teacher_id = %s
        """, (lesson_id, course_id, teacher_id))
        if not cur.fetchone():
            return False
        cur.execute("""
            DELETE FROM homework_submissions
            WHERE homework_id IN (SELECT homework_id FROM homeworks WHERE lesson_id = %s)
        """, (lesson_id,))
        cur.execute("DELETE FROM lessons WHERE lesson_id = %s", (lesson_id,))
        return True


def add_homework(teacher_id, lesson_id, description):
    with tx() as cur:
        cur.execute("""
            INSERT INTO homeworks (lesson_id, description)
            SELECT l.lesson_id, %s FROM lessons l JOIN courses c ON c.course_id = l.course_id
            WHERE l.lesson_id = %s AND c.teacher_id = %s
        """, (description, lesson_id, teacher_id))
        return cur.rowcount == 1


def submissions(teacher_id, course_id):
    return query("""
        SELECT sub.submission_id AS id, st.first_name || ' ' || st.last_name AS student,
               l.title AS lesson, sub.file_url, sub.grade
        FROM homework_submissions sub
        JOIN homeworks h ON h.homework_id = sub.homework_id
        JOIN lessons l   ON l.lesson_id = h.lesson_id
        JOIN courses c   ON c.course_id = l.course_id
        JOIN students st ON st.student_id = sub.student_id
        WHERE c.course_id = %s AND c.teacher_id = %s
        ORDER BY sub.submission_id
    """, (course_id, teacher_id))


def grade(teacher_id, submission_id, value):
    with tx() as cur:
        cur.execute("""
            UPDATE homework_submissions sub SET grade = %s
            FROM homeworks h, lessons l, courses c
            WHERE sub.homework_id = h.homework_id AND h.lesson_id = l.lesson_id
              AND l.course_id = c.course_id
              AND sub.submission_id = %s AND c.teacher_id = %s
        """, (value, submission_id, teacher_id))
        return cur.rowcount == 1
