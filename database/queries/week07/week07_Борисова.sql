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


UPDATE homework_submissions
SET grade = 9
WHERE submission_id = 1;


DELETE FROM homework_submissions
WHERE submission_id = 1
  AND student_id = 2
  AND grade IS NULL;


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