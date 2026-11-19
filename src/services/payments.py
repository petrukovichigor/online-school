"""Subscription and payment status changes: "payment first, then access"."""
import secrets

from src.db.connection import tx


def new_transaction_id():
    """Same format as the seed data: TXN- and 10 digits (no leading zero)."""
    return f"TXN-{secrets.randbelow(9 * 10**9) + 10**9}"


def buy(student_id, course_id):
    """Buy: subscription and payment start as pending. Buying again after a cancellation updates the same payment."""
    with tx() as cur:
        cur.execute("""
            INSERT INTO course_subscriptions (student_id, course_id) VALUES (%s, %s)
            ON CONFLICT (student_id, course_id) DO UPDATE SET status = 'pending'
                WHERE course_subscriptions.status = 'cancelled'
            RETURNING subscr_id
        """, (student_id, course_id))
        row = cur.fetchone()
        if not row:  # already pending or active
            return False
        cur.execute("""
            INSERT INTO payments (subscr_id, amount)
            SELECT %s, price FROM courses WHERE course_id = %s
            ON CONFLICT (subscr_id) DO UPDATE
                SET amount = EXCLUDED.amount, status = 'pending', transaction_id = NULL
        """, (row["subscr_id"], course_id))
        return True


def pay(student_id, course_id):
    """Payment succeeded: payment becomes paid with a transaction id, subscription becomes active."""
    with tx() as cur:
        cur.execute("""
            UPDATE payments p SET status = 'paid', transaction_id = %s
            FROM course_subscriptions s
            WHERE p.subscr_id = s.subscr_id AND s.student_id = %s AND s.course_id = %s
              AND s.status = 'pending' AND p.status = 'pending'
            RETURNING s.subscr_id
        """, (new_transaction_id(), student_id, course_id))
        row = cur.fetchone()
        if not row:
            return False
        cur.execute("UPDATE course_subscriptions SET status = 'active' WHERE subscr_id = %s",
                    (row["subscr_id"],))
        return True


def refund(student_id, course_id):
    """Refund: payment becomes refunded, subscription becomes cancelled, access is closed."""
    with tx() as cur:
        cur.execute("""
            UPDATE payments p SET status = 'refunded'
            FROM course_subscriptions s
            WHERE p.subscr_id = s.subscr_id AND s.student_id = %s AND s.course_id = %s
              AND s.status = 'active' AND p.status = 'paid'
            RETURNING s.subscr_id
        """, (student_id, course_id))
        row = cur.fetchone()
        if not row:
            return False
        cur.execute("UPDATE course_subscriptions SET status = 'cancelled' WHERE subscr_id = %s",
                    (row["subscr_id"],))
        return True


def cancel(student_id, course_id):
    """Cancelling an unpaid order: delete the pending payment and subscription."""
    with tx() as cur:
        cur.execute("""
            SELECT subscr_id FROM course_subscriptions
            WHERE student_id = %s AND course_id = %s AND status = 'pending'
        """, (student_id, course_id))
        row = cur.fetchone()
        if not row:
            return False
        cur.execute("DELETE FROM payments WHERE subscr_id = %s", (row["subscr_id"],))
        cur.execute("DELETE FROM course_subscriptions WHERE subscr_id = %s", (row["subscr_id"],))
        return True
