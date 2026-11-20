-- 1. Студент сдаёт домашнее задание: загрузка файла (кнопка «Сдать работу»)
INSERT INTO homework_submissions (
    homework_id,
    student_id,
    file_url
)
VALUES (
    1,
    2,
    'https://example.com/files/homework_1.pdf'
);

-- 2. Преподаватель выставляет оценку за работу
UPDATE homework_submissions
SET grade = 9
WHERE submission_id = 1;

-- 3. Студент забирает свою работу до проверки, чтобы загрузить новый файл
DELETE FROM homework_submissions
WHERE submission_id = 1
  AND student_id = 2
  AND grade IS NULL;

-- 4. Пересдача: старая работа удаляется, новая загружается, одним действием
BEGIN;

DELETE FROM homework_submissions
WHERE homework_id = 3
  AND student_id = 2
  AND grade IS NULL;

INSERT INTO homework_submissions (
    homework_id,
    student_id,
    file_url
)
VALUES (
    3,
    2,
    'https://example.com/files/new_homework_3.pdf'
);

COMMIT;

-- 5. Журнал оценок студента: курс, урок, задание, оценка (экран «Мои оценки»)
CREATE OR REPLACE VIEW student_gradebook AS

SELECT
    hs.student_id,
    c.title AS course_title,
    l.title AS lesson_title,
    h.homework_id,
    h.description AS homework_description,
    hs.grade

FROM homework_submissions hs

JOIN homeworks h
    ON h.homework_id = hs.homework_id

JOIN lessons l
    ON l.lesson_id = h.lesson_id

JOIN courses c
    ON c.course_id = l.course_id;

-- 6. Работы, ожидающие проверки, по преподавателям (уведомление в кабинете)
CREATE OR REPLACE VIEW pending_submissions_by_teacher AS

SELECT
    t.teacher_id,
    t.first_name,
    t.last_name,
    c.title AS course_title,
    l.title AS lesson_title,
    h.homework_id,
    h.description AS homework_description,
    hs.submission_id,
    hs.student_id,
    hs.file_url

FROM teachers t

         JOIN courses c
              ON c.teacher_id = t.teacher_id

         JOIN lessons l
              ON l.course_id = c.course_id

         JOIN homeworks h
              ON h.lesson_id = l.lesson_id

         JOIN homework_submissions hs
              ON hs.homework_id = h.homework_id

WHERE hs.grade IS NULL;