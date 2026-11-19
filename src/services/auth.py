import bcrypt


def hash_password(password: str) -> str:
    """60 characters, as required by the CHECK constraint in the DB."""
    return bcrypt.hashpw(password.encode()[:72], bcrypt.gensalt()).decode()


def check_password(password: str, password_hash: str) -> bool:
    try:
        return bcrypt.checkpw(password.encode()[:72], password_hash.encode())
    except ValueError:  # the stored value is not a bcrypt hash
        return False
