-- 1. Записать студента на курс: создать подписку со статусом pending
INSERT INTO course_subscriptions (student_id, course_id, status)
VALUES (1, 4, 'pending')
RETURNING subscr_id, student_id, course_id, status;


-- 2. Отменить подписку студента, пока она не оплачена (статус cancelled)
UPDATE course_subscriptions
SET status = 'cancelled'
WHERE student_id = 1
  AND course_id = 4
  AND status = 'pending'
RETURNING subscr_id, student_id, course_id, status;


-- 3. Удалить неоплаченную заявку на курс вместе с её платежом в статусе pending
BEGIN;

DELETE FROM payments
WHERE subscr_id IN (
    SELECT subscr_id
    FROM course_subscriptions
    WHERE student_id = 10
      AND course_id = 3
      AND status = 'pending'
)
  AND status = 'pending';

DELETE FROM course_subscriptions
WHERE student_id = 10
  AND course_id = 3
  AND status = 'pending'
RETURNING subscr_id, student_id, course_id, status;

COMMIT;


-- 4. Оплата курса: платёж становится paid с номером транзакции
BEGIN;

UPDATE payments
SET status = 'paid',
    transaction_id = '9f8e7d6c-5b4a-3210-fedc-ba9876543210'
WHERE subscr_id = 219
  AND status = 'pending';


UPDATE course_subscriptions
SET status = 'active'
WHERE subscr_id = 219
  AND status = 'pending'

RETURNING subscr_id, student_id, course_id, status;

COMMIT;


-- 5. Каталог курсов: категория, преподаватель, цена, число уроков
CREATE OR REPLACE VIEW v_courses_catalog AS
SELECT 
    courses.course_id,
    courses.title AS course_title,
    courses.description AS course_description,
    categories.name AS category_name,
    teachers.first_name || ' ' || teachers.last_name AS teacher_name,
    courses.price,
    COUNT(lessons.lesson_id) AS lessons_count
FROM courses
JOIN categories ON courses.category_id = categories.category_id
JOIN teachers ON courses.teacher_id = teachers.teacher_id
LEFT JOIN lessons ON lessons.course_id = courses.course_id
GROUP BY 
    courses.course_id,
    courses.title,
    courses.description,
    categories.name,
    teachers.first_name,
    teachers.last_name,
    courses.price
ORDER BY courses.course_id;


-- 6. История оплат студентов: курс, сумма, статус платежа и статус подписки
CREATE OR REPLACE VIEW v_student_payments_history AS
SELECT 
    payments.payment_id,
    students.student_id,
    students.first_name || ' ' || students.last_name AS student_name,
    students.email AS student_email,
    courses.course_id,
    courses.title AS course_title,
    payments.amount,
    payments.status AS payment_status,
    payments.transaction_id,
    course_subscriptions.status AS subscription_status
FROM payments
JOIN course_subscriptions ON payments.subscr_id = course_subscriptions.subscr_id
JOIN students ON course_subscriptions.student_id = students.student_id
JOIN courses ON course_subscriptions.course_id = courses.course_id
ORDER BY payments.payment_id DESC;


