-- Курсы, на которые студент 30 ещё не подписан
SELECT course_id, title
FROM courses
WHERE course_id NOT IN (
    SELECT course_id
    FROM course_subscriptions
    WHERE student_id = 30
)
ORDER BY course_id;

-- Курсы, на которые студент 30 ещё не подписан В РАМКАХ СВОИХ КАТЕГОРИЙ
SELECT course_id, title
FROM courses
WHERE course_id NOT IN (
    SELECT course_id
    FROM course_subscriptions
    WHERE student_id = 30
)
AND category_id IN (
    SELECT category_id
    FROM course_subscriptions
    JOIN courses ON courses.course_id = course_subscriptions.course_id
    WHERE student_id = 30
)
ORDER BY course_id;

-- Студенты, которые ни разу не оплатили курс [NOT EXISTS]
-- Каждый курс, его цена и разница со средней ценой своей категории [подзапрос в SELECT]
-- Топ-3 курса по выручке от оплаченных подписок [CTE]
-- Выручка по категориям и доля каждой в общей выручке, в процентах (финансовый отчёт) [аналитический: JOIN + CTE + SUM]