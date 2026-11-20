SELECT
    h.homework_id,
    h.description,
    h.lesson_id
FROM homeworks h
WHERE h.homework_id = ANY (
    SELECT hs.homework_id
    FROM homework_submissions hs
    WHERE hs.grade = 10
);

SELECT
    h.homework_id,
    h.description,
    h.lesson_id
FROM homeworks h
WHERE NOT EXISTS (
    SELECT 1
    FROM homework_submissions hs
    WHERE hs.homework_id = h.homework_id
);

SELECT
    s.student_id,
    s.first_name,
    s.last_name,

    (
        SELECT COUNT(*)
        FROM homework_submissions hs
        WHERE hs.student_id = s.student_id
    ) AS submitted_works_count,

    (
        SELECT ROUND(AVG(hs.grade), 2)
        FROM homework_submissions hs
        WHERE hs.student_id = s.student_id
    ) AS average_grade

FROM students s;

WITH course_progress AS (
    SELECT
        c.course_id,
        c.title AS course_title,

        COUNT(h.homework_id) AS total_homeworks,

        COUNT(hs.submission_id) AS submitted_homeworks

    FROM course_subscriptions cs

    JOIN courses c
        ON c.course_id = cs.course_id

    LEFT JOIN lessons l
        ON l.course_id = c.course_id

    LEFT JOIN homeworks h
        ON h.lesson_id = l.lesson_id

    LEFT JOIN homework_submissions hs
        ON hs.homework_id = h.homework_id
        AND hs.student_id = cs.student_id

    WHERE cs.student_id = 1
      AND cs.status = 'active'

    GROUP BY
        c.course_id,
        c.title
)

SELECT
    course_id,
    course_title,
    total_homeworks,
    submitted_homeworks,

    CASE
        WHEN total_homeworks = 0 THEN 0
        ELSE ROUND(
            submitted_homeworks * 100.0 / total_homeworks,
            2
        )
    END AS progress_percent

FROM course_progress;

SELECT
    c.course_id,
    c.title AS course_title,
    ROUND(AVG(hs.grade), 2) AS course_average_grade

FROM courses c

JOIN lessons l
    ON l.course_id = c.course_id

JOIN homeworks h
    ON h.lesson_id = l.lesson_id

JOIN homework_submissions hs
    ON hs.homework_id = h.homework_id

WHERE hs.grade IS NOT NULL

GROUP BY
    c.course_id,
    c.title

HAVING AVG(hs.grade) < (
    SELECT AVG(grade)
    FROM homework_submissions
    WHERE grade IS NOT NULL
)

ORDER BY course_average_grade ASC;