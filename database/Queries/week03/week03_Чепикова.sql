SELECT
    lesson_id,
    title,
    course_id
FROM lessons
WHERE title LIKE '%Basic%'
ORDER BY lesson_id;

SELECT
    teacher_id,
    first_name,
    last_name,
    salary,
    ROUND(salary * 0.87, 2) AS salary_after_tax
FROM teachers
WHERE salary BETWEEN 1800 AND 2200
ORDER BY salary DESC;

SELECT
    teacher_id,
    first_name,
    last_name,
    email,
    phone_number
FROM teachers
WHERE phone_number IS NULL
ORDER BY teacher_id;

SELECT
    lesson_id,
    course_id,
    position,
    title
FROM lessons
WHERE course_id IN (1, 2, 3)
  AND (position = 1 OR position = 2 or position = 3)
ORDER BY course_id, position;

SELECT DISTINCT
    s.student_id,
    s.first_name,
    s.last_name,
    s.email
FROM students s
JOIN course_subscriptions cs
    ON cs.student_id = s.student_id
WHERE cs.status = 'active'
ORDER BY s.student_id;
