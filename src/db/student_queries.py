from src.db.connection import query, tx

# lessons and assignments are available only with an active subscription
_ACCESS = """
    JOIN lessons l ON l.lesson_id = h.lesson_id
    JOIN course_subscriptions cs ON cs.course_id = l.course_id
         AND cs.student_id = %s AND cs.status = 'active'
"""


def subscriptions(student_id):
    rows = query("SELECT course_id, status FROM course_subscriptions WHERE student_id = %s",
                 (student_id,))
    return {r["course_id"]: r["status"] for r in rows}


def payments(student_id):
    rows = query("""
        SELECT c.title AS course, p.amount, p.status, COALESCE(p.transaction_id, '') AS tx
        FROM payments p
        JOIN course_subscriptions s ON s.subscr_id = p.subscr_id
        JOIN courses c ON c.course_id = s.course_id
        WHERE s.student_id = %s
        ORDER BY p.payment_id DESC
    """, (student_id,))
    for r in rows:
        r["amount"] = float(r["amount"])
    return rows


def lessons(student_id, course_id):
    return query("""
        SELECT l.lesson_id AS id, l.position, l.title,
               CASE WHEN s.status = 'active' THEN l.video_url ELSE '' END AS video_url
        FROM lessons l
        LEFT JOIN course_subscriptions s ON s.course_id = l.course_id AND s.student_id = %s
        WHERE l.course_id = %s
        ORDER BY l.position
    """, (student_id, course_id))


def homework(student_id, lesson_id):
    rows = query(f"""
        SELECT h.homework_id, h.description, sub.file_url, sub.grade
        FROM homeworks h {_ACCESS}
        LEFT JOIN homework_submissions sub
               ON sub.homework_id = h.homework_id AND sub.student_id = %s
        WHERE h.lesson_id = %s
        ORDER BY h.homework_id LIMIT 1
    """, (student_id, student_id, lesson_id))
    return rows[0] if rows else None


def submit_homework(student_id, lesson_id, file_url):
    """Submit work. Work that is already graded (grade is not NULL) cannot be resubmitted."""
    with tx() as cur:
        cur.execute(f"""
            SELECT h.homework_id FROM homeworks h {_ACCESS}
            WHERE h.lesson_id = %s ORDER BY h.homework_id LIMIT 1
        """, (student_id, lesson_id))
        row = cur.fetchone()
        if not row:
            return False
        cur.execute("""
            INSERT INTO homework_submissions (homework_id, student_id, file_url)
            VALUES (%s, %s, %s)
            ON CONFLICT (homework_id, student_id) DO UPDATE SET file_url = EXCLUDED.file_url
                WHERE homework_submissions.grade IS NULL
        """, (row["homework_id"], student_id, file_url))
        return cur.rowcount == 1


def grades(student_id):
    return query("""
        SELECT c.title AS course, l.title AS lesson, s.grade
        FROM homework_submissions s
        JOIN homeworks h ON h.homework_id = s.homework_id
        JOIN lessons l   ON l.lesson_id = h.lesson_id
        JOIN courses c   ON c.course_id = l.course_id
        WHERE s.student_id = %s
        ORDER BY c.title, l.position
    """, (student_id,))
