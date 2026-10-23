--Все запросы с сортировками
--Количество платежей в каждом статусе
SELECT status, COUNT(payment_id) number_of_payments
FROM payments
GROUP BY status
ORDER BY number_of_payments DESC;

--Общая сумма платежей по статусам, кроме pending
SELECT status, SUM(amount) sum_of_payments
FROM payments
WHERE status <> 'pending'
GROUP BY status
ORDER BY sum_of_payments DESC;

--Средняя цена курса в каждой категории
SELECT category_id, ROUND(AVG(price),2) average_price
FROM courses
GROUP BY category_id
ORDER BY category_id;

--Самый дешёвый и самый дорогой курс у каждого преподавателя
SELECT teacher_id, MIN(price) cheapest_course, MAX(price) most_expensive_course
FROM courses
GROUP BY teacher_id
ORDER BY teacher_id;

--Преподаватели, которые ведут 2 и более курса в одной категории
SELECT teacher_id, COUNT(course_id) number_of_courses
FROM courses
GROUP BY teacher_id, category_id
HAVING COUNT(course_id) >= 2
ORDER BY number_of_courses DESC;