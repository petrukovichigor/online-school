--Студенты на курсах конкретного преподавателя с активной подпиской [INNER JOIN]
SELECT DISTINCT
    students.student_id,
    students.first_name,
    students.last_name,
    title AS course_title
FROM students
INNER JOIN course_subscriptions ON students.student_id = course_subscriptions.student_id
INNER JOIN courses ON course_subscriptions.course_id = courses.course_id
INNER JOIN teachers ON courses.teacher_id = teachers.teacher_id
WHERE status = 'active'
  AND teachers.teacher_id = 2;

--Программа курса: уроки по порядку и задания к ним, включая уроки без заданий [LEFT JOIN]
SELECT
    lessons.course_id,
    title AS lesson_title,
    position AS lesson_position,
    homework_id,
    description AS homework_description
FROM lessons
LEFT JOIN homeworks ON lessons.lesson_id = homeworks.lesson_id
ORDER BY lessons.course_id, position;

--Преподаватели, у которых нет ни одного курса [RIGHT JOIN]
SELECT
    teachers.teacher_id, 
    teachers.first_name,
    teachers.last_name
FROM courses
RIGHT JOIN teachers ON courses.teacher_id = teachers.teacher_id
WHERE courses.course_id IS NULL;

-- Уроки, доступные конкретному студенту по его активным подпискам (экран «Мои курсы») [INNER JOIN]
SELECT
    lessons.lesson_id,
    lessons.title AS lesson_title,
    lessons.course_id
FROM lessons
INNER JOIN courses ON lessons.course_id = courses.course_id
INNER JOIN course_subscriptions ON courses.course_id = course_subscriptions.course_id
WHERE course_subscriptions.status = 'active'
  AND course_subscriptions.student_id = 1;


--Студенты, которые учатся одновременно на курсе программирования и на языковом курсе [INTERSECT]
SELECT student_id
FROM course_subscriptions
INNER JOIN courses ON course_subscriptions.course_id = courses.course_id
INNER JOIN categories ON courses.category_id = categories.category_id
WHERE (name LIKE 'Programming') AND status = 'active'

INTERSECT

SELECT student_id
FROM course_subscriptions
INNER JOIN courses ON course_subscriptions.course_id = courses.course_id
INNER JOIN categories ON courses.category_id = categories.category_id
WHERE (name LIKE 'Foreign Languages') AND status = 'active'
ORDER BY student_id;
