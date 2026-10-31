-- Курсы, на которые студент ещё не подписан
SELECT course_id, title
FROM courses
WHERE course_id NOT IN (SELECT course_id FROM course_subscriptions WHERE student_id = :student_id)
ORDER BY course_id;

-- Курсы, на которые студент ещё не подписан В РАМКАХ СВОИХ КАТЕГОРИЙ
SELECT course_id, title
FROM courses
WHERE course_id NOT IN (SELECT course_id FROM course_subscriptions WHERE student_id = :student_id)
  AND category_id IN (SELECT category_id
                      FROM course_subscriptions
                               JOIN courses ON courses.course_id = course_subscriptions.course_id
                      WHERE student_id = :student_id)
ORDER BY course_id;

-- Студенты, которые ни разу не оплатили курс
SELECT students.first_name || ' ' || students.last_name AS student
FROM students
WHERE NOT EXISTS
          (SELECT 1
           FROM course_subscriptions
           WHERE course_subscriptions.student_id = students.student_id
             AND status IN ('active', 'cancelled'))
ORDER BY student;

-- Каждый курс, его цена и разница со средней ценой своей категории
SELECT c1.title,
       c1.price,
       c1.price -
       ROUND((SELECT AVG(c2.price) FROM courses c2 WHERE c2.category_id = c1.category_id), 2) AS difference_avg
FROM courses c1;

-- Топ-3 курсов сверху и снизу по выручке, но если у нескольких курсов выручка одинаковая, вывести их все
-- Через CTE и DENSE_RANK
WITH RankedCourses AS (SELECT courses.course_id,
                              SUM(courses.price)                                   AS revenue,
                              DENSE_RANK() OVER (ORDER BY SUM(courses.price) DESC) AS rank_top,
                              DENSE_RANK() OVER (ORDER BY SUM(courses.price))      AS rank_bottom
                       FROM courses
                                JOIN course_subscriptions ON courses.course_id = course_subscriptions.course_id
                       GROUP BY courses.course_id)

(SELECT 'Лучшие' AS status, rank_top AS rank, title, revenue
 FROM RankedCourses
           JOIN courses ON RankedCourses.course_id = courses.course_id
 WHERE rank_top <= 3
 ORDER BY revenue DESC)

UNION ALL

(SELECT 'Худшие' AS status, rank_bottom AS rank, title, revenue
 FROM RankedCourses
          JOIN courses ON RankedCourses.course_id = courses.course_id
 WHERE rank_bottom <= 3
 ORDER BY revenue);

-- Выручка по категориям и доля каждой в общей выручке, в процентах (финансовый отчёт)
-- С использованием SUM() OVER()
WITH CategoryRevenue AS (SELECT categories.name    AS category_name,
                                SUM(courses.price) AS category_revenue
                         FROM courses
                                  JOIN course_subscriptions ON courses.course_id = course_subscriptions.course_id
                                  JOIN categories ON courses.category_id = categories.category_id
                         GROUP BY categories.name)
SELECT category_name,
       category_revenue,
       ROUND((category_revenue * 100.0) / SUM(category_revenue) OVER (), 2) AS share_percentage
FROM CategoryRevenue
ORDER BY share_percentage DESC;
