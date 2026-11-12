-- 1. Курсы дороже всех языковых курсов
 
SELECT 
    courses.course_id,
    courses.title AS course_title,
    categories.name AS category_name,
    courses.price
FROM courses
JOIN categories ON courses.category_id = categories.category_id
WHERE courses.price > ALL (
    SELECT price
    FROM courses
    WHERE category_id = (
        SELECT category_id 
        FROM categories 
        WHERE name = 'Foreign Languages'
    )
)
ORDER BY courses.price DESC, courses.course_id;


-- 2. Преподаватели, у которых есть работы на проверку (уведомление в кабинете)

SELECT 
    teachers.teacher_id,
    teachers.first_name,
    teachers.last_name,
    teachers.email
FROM teachers
WHERE EXISTS (
    SELECT 1
    FROM courses
    JOIN lessons ON lessons.course_id = courses.course_id
    JOIN homeworks ON homeworks.lesson_id = lessons.lesson_id
    JOIN homework_submissions ON homework_submissions.homework_id = homeworks.homework_id
    WHERE courses.teacher_id = teachers.teacher_id
      AND homework_submissions.grade IS NULL
)
ORDER BY teachers.teacher_id;


-- 3. Средняя и максимальная нагрузка преподавателя по числу активных студентов
-- Учитываются все преподаватели, включая тех, у кого сейчас 0 активных студентов

SELECT 
    ROUND(AVG(teacher_load.active_students_count), 2) AS avg_active_students_per_teacher,
    MAX(teacher_load.active_students_count) AS max_active_students_per_teacher
FROM (
    SELECT 
        teachers.teacher_id,
        COUNT(course_subscriptions.subscr_id) AS active_students_count
    FROM teachers
    LEFT JOIN courses ON courses.teacher_id = teachers.teacher_id
    LEFT JOIN course_subscriptions 
        ON course_subscriptions.course_id = courses.course_id 
        AND course_subscriptions.status = 'active'
    GROUP BY teachers.teacher_id
) AS teacher_load;


-- 4. Курсы, у которых активных студентов больше среднего по школе 

WITH course_active_students AS (
    SELECT 
        courses.course_id,
        courses.title AS course_title,
        COUNT(course_subscriptions.subscr_id) AS active_students_count
    FROM courses
    LEFT JOIN course_subscriptions 
        ON course_subscriptions.course_id = courses.course_id 
        AND course_subscriptions.status = 'active'
    GROUP BY courses.course_id, courses.title
)
SELECT 
    course_active_students.course_id,
    course_active_students.course_title,
    course_active_students.active_students_count,
    ROUND((SELECT AVG(active_students_count) FROM course_active_students), 2) AS school_avg_students
FROM course_active_students
WHERE course_active_students.active_students_count > (
    SELECT AVG(active_students_count) 
    FROM course_active_students
)
ORDER BY course_active_students.active_students_count DESC, course_active_students.course_id;


-- 5. Рейтинг преподавателей: число студентов, выручка, средняя оценка по их курсам, место в рейтинге

WITH teacher_students_revenue AS (
    SELECT 
        teachers.teacher_id,
        COUNT(DISTINCT CASE WHEN course_subscriptions.status = 'active' THEN course_subscriptions.student_id END) AS active_students_count,
        COALESCE(SUM(CASE WHEN payments.status = 'paid' THEN payments.amount ELSE 0 END), 0.00) AS total_revenue
    FROM teachers
    LEFT JOIN courses ON courses.teacher_id = teachers.teacher_id
    LEFT JOIN course_subscriptions ON course_subscriptions.course_id = courses.course_id
    LEFT JOIN payments ON payments.subscr_id = course_subscriptions.subscr_id
    GROUP BY teachers.teacher_id
),
teacher_grades AS (
    SELECT 
        teachers.teacher_id,
        ROUND(AVG(homework_submissions.grade), 2) AS avg_grade
    FROM teachers
    LEFT JOIN courses ON courses.teacher_id = teachers.teacher_id
    LEFT JOIN lessons ON lessons.course_id = courses.course_id
    LEFT JOIN homeworks ON homeworks.lesson_id = lessons.lesson_id
    LEFT JOIN homework_submissions ON homework_submissions.homework_id = homeworks.homework_id
    GROUP BY teachers.teacher_id
)
SELECT 
    DENSE_RANK() OVER (
        ORDER BY 
            teacher_students_revenue.total_revenue DESC, 
            teacher_students_revenue.active_students_count DESC, 
            teacher_grades.avg_grade DESC NULLS LAST
    ) AS rating_place,
    teachers.teacher_id,
    teachers.first_name,
    teachers.last_name,
    teachers.email,
    teacher_students_revenue.active_students_count,
    teacher_students_revenue.total_revenue,
    teacher_grades.avg_grade
FROM teachers
JOIN teacher_students_revenue ON teachers.teacher_id = teacher_students_revenue.teacher_id
JOIN teacher_grades ON teachers.teacher_id = teacher_grades.teacher_id
ORDER BY rating_place, teachers.teacher_id;