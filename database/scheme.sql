BEGIN;

CREATE TABLE categories (
    category_id  SERIAL       PRIMARY KEY,
    name         VARCHAR(50)  NOT NULL UNIQUE,

    CONSTRAINT categories_name_not_blank CHECK (btrim(name) <> '')
);

CREATE TABLE teachers (
    teacher_id     SERIAL         PRIMARY KEY,
    first_name     VARCHAR(50)    NOT NULL,
    last_name      VARCHAR(50)    NOT NULL,
    email          VARCHAR(255)   NOT NULL UNIQUE,
    password_hash  VARCHAR(60)    NOT NULL,
    phone_number   VARCHAR(13),
    salary         DECIMAL(10, 2),

    CONSTRAINT teachers_names_not_blank CHECK (btrim(first_name) <> '' AND btrim(last_name) <> ''),
    CONSTRAINT teachers_email_format    CHECK (email ~ '^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$'),
    CONSTRAINT teachers_password_bcrypt CHECK (password_hash ~ '^\$2[aby]\$[0-9]{2}\$.{53}$'),
    CONSTRAINT teachers_phone_format    CHECK (phone_number ~ '^\+375(25|29|33|44)[0-9]{7}$'),
    CONSTRAINT teachers_salary_positive CHECK (salary > 0)
);

CREATE TABLE students (
    student_id     SERIAL         PRIMARY KEY,
    first_name     VARCHAR(50)    NOT NULL,
    last_name      VARCHAR(50)    NOT NULL,
    email          VARCHAR(255)   NOT NULL UNIQUE,
    password_hash  VARCHAR(60)    NOT NULL,
    phone_number   VARCHAR(13),

    CONSTRAINT students_names_not_blank CHECK (btrim(first_name) <> '' AND btrim(last_name) <> ''),
    CONSTRAINT students_email_format    CHECK (email ~ '^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$'),
    CONSTRAINT students_password_bcrypt CHECK (password_hash ~ '^\$2[aby]\$[0-9]{2}\$.{53}$'),
    CONSTRAINT students_phone_format    CHECK (phone_number ~ '^\+375(25|29|33|44)[0-9]{7}$')
);

CREATE TABLE courses (
    course_id    SERIAL          PRIMARY KEY,
    title        VARCHAR(150)    NOT NULL UNIQUE,
    description  TEXT,
    price        DECIMAL(10, 2)  NOT NULL,
    category_id  INTEGER         NOT NULL REFERENCES categories (category_id) ON DELETE RESTRICT,
    teacher_id   INTEGER         NOT NULL REFERENCES teachers (teacher_id)    ON DELETE RESTRICT,

    CONSTRAINT courses_title_not_blank CHECK (btrim(title) <> ''),
    CONSTRAINT courses_price_positive  CHECK (price > 0)
);

CREATE TABLE lessons (
    lesson_id  SERIAL        PRIMARY KEY,
    position   INTEGER       NOT NULL,
    course_id  INTEGER       NOT NULL REFERENCES courses (course_id) ON DELETE CASCADE,
    title      VARCHAR(150)  NOT NULL,
    video_url  VARCHAR(500)  NOT NULL,

    CONSTRAINT lessons_course_position_unique UNIQUE (course_id, position),
    CONSTRAINT lessons_position_positive      CHECK (position > 0),
    CONSTRAINT lessons_title_not_blank        CHECK (btrim(title) <> ''),
    CONSTRAINT lessons_video_youtube          CHECK (video_url ~ '^https://(www\.)?(youtube\.com|youtu\.be)/')
);

CREATE TABLE homeworks (
    homework_id  SERIAL   PRIMARY KEY,
    lesson_id    INTEGER  NOT NULL REFERENCES lessons (lesson_id) ON DELETE CASCADE,
    description  TEXT     NOT NULL,

    CONSTRAINT homeworks_description_not_blank CHECK (btrim(description) <> '')
);

CREATE TABLE course_subscriptions (
    subscr_id   SERIAL       PRIMARY KEY,
    student_id  INTEGER      NOT NULL REFERENCES students (student_id) ON DELETE RESTRICT,
    course_id   INTEGER      NOT NULL REFERENCES courses (course_id)   ON DELETE RESTRICT,
    status      VARCHAR(10)  NOT NULL DEFAULT 'pending',

    CONSTRAINT subscriptions_student_course_unique UNIQUE (student_id, course_id),
    CONSTRAINT subscriptions_status_valid          CHECK (status IN ('pending', 'active', 'cancelled'))
);

CREATE TABLE payments (
    payment_id      SERIAL          PRIMARY KEY,
    subscr_id       INTEGER         NOT NULL UNIQUE REFERENCES course_subscriptions (subscr_id) ON DELETE RESTRICT,
    amount          DECIMAL(10, 2)  NOT NULL,
    status          VARCHAR(10)     NOT NULL DEFAULT 'pending',
    transaction_id  VARCHAR(36)     UNIQUE,

    CONSTRAINT payments_amount_positive CHECK (amount > 0),
    CONSTRAINT payments_status_valid    CHECK (status IN ('pending', 'paid', 'refunded')),
    -- номер транзакции есть только у прошедшей оплаты (paid или refunded)
    CONSTRAINT payments_transaction_by_status CHECK ((status = 'pending') = (transaction_id IS NULL))
);

CREATE TABLE homework_submissions (
    submission_id  SERIAL        PRIMARY KEY,
    homework_id    INTEGER       NOT NULL REFERENCES homeworks (homework_id) ON DELETE RESTRICT,
    student_id     INTEGER       NOT NULL REFERENCES students (student_id)   ON DELETE CASCADE,
    file_url       VARCHAR(500)  NOT NULL,
    grade          INTEGER,

    CONSTRAINT submissions_homework_student_unique UNIQUE (homework_id, student_id),
    CONSTRAINT submissions_file_url_https          CHECK (file_url ~ '^https://'),
    CONSTRAINT submissions_grade_range             CHECK (grade BETWEEN 1 AND 10)
);

COMMIT;