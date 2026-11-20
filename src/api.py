"""Python functions called by the interface: pywebview.api.<name>.
Public methods are available from JS; names starting with "_" are hidden."""
import functools
import time
import traceback

import psycopg2.errors

from src.db import auth_queries, catalog_queries as cat, student_queries as stu, teacher_queries as tea
from src.db.connection import current_actor
from src.services import auth, payments


def access(*roles):
    """Allows only signed-in users with the required role. DB errors are printed to the console and None is returned."""
    def deco(fn):
        @functools.wraps(fn)
        def wrapper(self, *args):
            if not self._user or (roles and self._user["role"] not in roles):
                return None
            token = current_actor.set(f"{self._user['role']}:{self._user['id']}")  # goes to audit_log.actor
            try:
                for attempt in (1, 2):
                    started = time.perf_counter()
                    try:
                        result = fn(self, *args)
                        print(f"[api] {fn.__name__}: {(time.perf_counter() - started) * 1000:.0f} ms")
                        return result
                    except (psycopg2.OperationalError, psycopg2.InterfaceError):
                        if attempt == 2:  # a stale pooled connection is retried once
                            traceback.print_exc()
                    except Exception:
                        traceback.print_exc()
                        return None
                return None
            finally:
                current_actor.reset(token)
        return wrapper
    return deco


class Api:
    def __init__(self):
        self._user = None  # {'role': 'student'|'teacher', 'id': int, 'name': str, 'email': str}

    def _set_user(self, role, row):
        self._user = {"role": role, "id": row["id"], "email": row["email"],
                      "name": f"{row['first_name']} {row['last_name']}"}

    # ---------- sign in ----------
    def login(self, role, email, password):
        try:
            if role not in auth_queries.TABLES:
                return {"ok": False, "error": "Unknown role"}
            row = auth_queries.find_user(role, (email or "").strip().lower())
            if not row or not auth.check_password(password or "", row["password_hash"]):
                return {"ok": False, "error": "Wrong email or password"}
            self._set_user(role, row)
            return {"ok": True, "role": role}
        except Exception:
            traceback.print_exc()
            return {"ok": False, "error": "Cannot reach the database"}

    def register(self, role, data):
        if role != "student":
            return {"ok": False, "error": "Registration is available to students only"}
        try:
            email = (data.get("email") or "").strip().lower()
            sid = auth_queries.create_student(
                (data.get("first_name") or "").strip(), (data.get("last_name") or "").strip(),
                email, (data.get("phone") or "").strip(), auth.hash_password(data.get("password") or ""))
            self._set_user("student", {"id": sid, "email": email,
                                       "first_name": data["first_name"].strip(), "last_name": data["last_name"].strip()})
            return {"ok": True, "role": "student"}
        except psycopg2.errors.UniqueViolation:
            return {"ok": False, "error": "This email is already registered"}
        except psycopg2.errors.CheckViolation:
            return {"ok": False, "error": "Check your email, name and phone"}
        except Exception:
            traceback.print_exc()
            return {"ok": False, "error": "Could not sign up"}

    def logout(self):
        self._user = None
        return True

    @access()
    def me(self):
        return {"name": self._user["name"], "email": self._user["email"]}

    # ---------- common ----------
    @access()
    def get_categories(self):
        return cat.categories()

    @access()
    def get_courses(self):
        return cat.courses()

    # ---------- student ----------
    @access("student")
    def get_subscriptions(self):
        return stu.subscriptions(self._user["id"])

    @access("student")
    def get_payments(self):
        return stu.payments(self._user["id"])

    @access("student")
    def get_lessons(self, course_id):
        return stu.lessons(self._user["id"], course_id)

    @access("student")
    def get_homework(self, lesson_id):
        return stu.homework(self._user["id"], lesson_id)

    @access("student")
    def get_grades(self):
        return stu.grades(self._user["id"])

    @access("student")
    def buy_course(self, course_id):
        return payments.buy(self._user["id"], course_id)

    @access("student")
    def pay_course(self, course_id):
        return payments.pay(self._user["id"], course_id)

    @access("student")
    def cancel_course(self, course_id):
        return payments.cancel(self._user["id"], course_id)

    @access("student")
    def refund_course(self, course_id):
        return payments.refund(self._user["id"], course_id)

    @access("student")
    def submit_homework(self, lesson_id, file_url):
        if not str(file_url).startswith("https://"):
            return False
        return stu.submit_homework(self._user["id"], lesson_id, file_url)

    # ---------- teacher ----------
    @access("teacher")
    def t_courses(self):
        return tea.courses(self._user["id"])

    @access("teacher")
    def t_create_course(self, d):
        if not d.get("title", "").strip() or not float(d.get("price", 0)) > 0:
            return False
        return tea.create_course(self._user["id"], d["title"].strip(), d["category"], d["price"], d.get("description", "").strip())

    @access("teacher")
    def t_students(self, course_id):
        return tea.students(self._user["id"], course_id)

    @access("teacher")
    def t_lessons(self, course_id):
        return tea.lessons(self._user["id"], course_id)

    @access("teacher")
    def t_add_lesson(self, course_id, d):
        return tea.add_lesson(self._user["id"], course_id, d["position"], d["title"].strip(), d["video_url"].strip())

    @access("teacher")
    def t_delete_lesson(self, course_id, lesson_id):
        return tea.delete_lesson(self._user["id"], course_id, lesson_id)

    @access("teacher")
    def t_add_homework(self, lesson_id, text):
        return tea.add_homework(self._user["id"], lesson_id, text.strip())

    @access("teacher")
    def t_submissions(self, course_id):
        return tea.submissions(self._user["id"], course_id)

    @access("teacher")
    def t_grade(self, submission_id, grade):
        if not 1 <= int(grade) <= 10:
            return False
        return tea.grade(self._user["id"], submission_id, int(grade))
