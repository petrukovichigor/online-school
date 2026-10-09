-- В каждом запросе применены сортировки
-- Какие студенты зарегистрированы с почтой на gmail.com
SELECT student_id,
       last_name,
       first_name,
       email
FROM students
WHERE email LIKE '%@gmail.com'
ORDER BY last_name, first_name;

-- Какие студенты не указали номер телефона (им нужно показать напоминание заполнить профиль)
SELECT student_id,
       last_name,
       first_name,
       email
FROM students
WHERE phone_number IS NULL
ORDER BY last_name;


-- Какие курсы стоят от 100 до 200 руб. и сколько они будут стоить со скидкой 20%?
SELECT course_id,
       title,
       price,
       ROUND(price * 0.8, 2) AS price_discount
FROM courses
WHERE price BETWEEN 100 AND 200
ORDER BY price, title;


-- Какие платежи требуют проверки: ожидают оплаты или возвращены, на сумму больше 150 руб. (проблемные платежи)
SELECT payment_id,
       subscr_id,
       amount,
       status
FROM payments
WHERE status IN ('pending', 'refunded')
  AND amount > 150
ORDER BY amount DESC;


-- Список всех цен курсов (варианты для фильтра «цена» в каталоге)
SELECT DISTINCT price
FROM courses
ORDER BY price;