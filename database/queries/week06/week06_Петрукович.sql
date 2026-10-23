-- Курсы, на которые студент 30 ещё не подписан
SELECT title
FROM courses
WHERE course_id NOT IN (
    SELECT course_id
    FROM course_subscriptions
    WHERE student_id = 30
)
ORDER BY title;

-- Курсы, на которые студент 30 ещё не подписан В РАМКАХ СВОИХ КАТЕГОРИЙ
SELECT title
FROM courses
WHERE course_id NOT IN (
    SELECT course_id
    FROM course_subscriptions
    WHERE student_id = 30
)
ORDER BY title;

-- Студенты, которые ни разу не оплатили курс [NOT EXISTS]
-- Каждый курс, его цена и разница со средней ценой своей категории [подзапрос в SELECT]
-- Топ-3 курса по выручке от оплаченных подписок [CTE]
-- Выручка по категориям и доля каждой в общей выручке, в процентах (финансовый отчёт) [аналитический: JOIN + CTE + SUM]