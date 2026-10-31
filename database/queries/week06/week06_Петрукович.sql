-- Курсы, на которые студент ещё не подписан
SELECT course_id, title
FROM courses
WHERE course_id NOT IN (SELECT course_id
                        FROM course_subscriptions
                        WHERE student_id = :student_id)
ORDER BY course_id;

-- Курсы, на которые студент ещё не подписан В РАМКАХ СВОИХ КАТЕГОРИЙ
SELECT course_id, title
FROM courses
WHERE course_id NOT IN (SELECT course_id
                        FROM course_subscriptions
                        WHERE student_id = :student_id)
  AND category_id IN (SELECT category_id
                      FROM course_subscriptions
                               JOIN courses ON courses.course_id = course_subscriptions.course_id
                      WHERE student_id = :student_id)
ORDER BY course_id;

-- Студенты, которые ни разу не оплатили курс
SELECT students.first_name || ' ' || students.last_name Student
FROM students
WHERE NOT EXISTS
          (SELECT 1
           FROM course_subscriptions
           WHERE course_subscriptions.student_id = students.student_id
             AND status IN ('active', 'cancelled'))
ORDER BY Student;

-- Каждый курс, его цена и разница со средней ценой своей категории
SELECT c1.title,
       c1.price,
       c1.price - ROUND((SELECT AVG(c2.price)
                         FROM courses c2
                         WHERE c2.category_id = c1.category_id), 2) difference_avg
FROM courses c1;

-- Топ-3 курса по выручке от оплаченных подписок [CTE]
-- Выручка по категориям и доля каждой в общей выручке, в процентах (финансовый отчёт) [аналитический: JOIN + CTE + SUM]