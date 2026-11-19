from contextlib import contextmanager

import psycopg2
import psycopg2.extras
from psycopg2 import pool

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
        print(f"Connection error: {error}")
        raise error


def test_connection():
    try:
        conn = get_db_connection()
        with conn.cursor() as cur:
            # The simplest test query
            cur.execute("SELECT version();")
            db_version = cur.fetchone()
            print("=== [DB] Connection established successfully! ===")
            print(f"=== [DB] Server version: {db_version[0]} ===")
        conn.close()
        return True
    except Exception as e:
        print("=== [DB] CRITICAL CONNECTION ERROR! ===")
        print(f"=== [DB] Error: {e} ===")
        return False


_pool = None


def _get_pool():
    """Connections are opened once and reused: a new connection to a remote DB costs several network round trips."""
    global _pool
    if _pool is None:
        _pool = pool.ThreadedConnectionPool(
            1, 5,
            host=config.DB_HOST, port=config.DB_PORT, database=config.DB_NAME,
            user=config.DB_USER, password=config.DB_PASSWORD,
            keepalives=1, keepalives_idle=30, keepalives_interval=10, keepalives_count=3,
        )
    return _pool


@contextmanager
def tx():
    """One transaction: commit on success, rollback on any error."""
    p = _get_pool()
    conn = p.getconn()
    broken = False
    try:
        with conn:
            with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
                yield cur
    except (psycopg2.OperationalError, psycopg2.InterfaceError):
        broken = True  # drop this connection, the next call opens a fresh one
        raise
    finally:
        p.putconn(conn, close=broken)


def query(sql, params=()):
    """SELECT -> list of dicts."""
    with tx() as cur:
        cur.execute(sql, params)
        return [dict(r) for r in cur.fetchall()]


def num(rows, *keys):
    """DECIMAL -> float, otherwise JS will not receive a number."""
    for r in rows:
        for k in keys:
            r[k] = float(r[k])
    return rows
