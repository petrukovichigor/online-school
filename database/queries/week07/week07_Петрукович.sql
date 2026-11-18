-- 1. Добавить новый урок в курс преподавателя
INSERT INTO lessons (position, course_id, title, video_url)
VALUES ((SELECT COALESCE(MAX(position), 0) + 1
         FROM lessons
         WHERE course_id = 52), 52, 'Leonardo Da Vinci', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ');

-- 1*. Добавим домашку этому уроку для 3. Допустим, в промежуток между этим и предыдущим запросом новые уроки не добавят
INSERT INTO homeworks (lesson_id, description)
VALUES ((SELECT MAX(lesson_id)
         FROM lessons), 'Complete the practice task for the lesson "Leonardo Da Vinci" and upload your file.');

-- 2. Изменить цену курса
UPDATE courses
SET price = 100
WHERE course_id = 52;

-- 3. Удалить урок вместе с его домашним заданием и сдачами работ (каскадное ПРИНУДИТЕЛЬНОЕ удаление ВСЕГО)
WITH target_lesson   AS (SELECT MAX(lesson_id) AS id
                         FROM lessons),
     del_submissions AS (
         DELETE FROM homework_submissions
             WHERE homework_id IN (SELECT homework_id
                                   FROM homeworks
                                   WHERE lesson_id = (SELECT id FROM target_lesson))),
     del_homeworks   AS (
         DELETE FROM homeworks
             WHERE lesson_id = (SELECT id FROM target_lesson))
DELETE
FROM lessons
WHERE lesson_id = (SELECT id FROM target_lesson);

-- 4. ТРАНЗАКЦИЯ С ROLLBACK: Возврат денег: платёж становится refunded, подписка становится cansalet.
BEGIN;
UPDATE payments
SET status = 'refunded'
WHERE payment_id = 298;
UPDATE course_subscriptions
SET status = 'cansalet' -- допущена ошибка, пройдет ROLLBACK
WHERE subscr_id = (SELECT subscr_id FROM payments WHERE payment_id = 298);
ROLLBACK;

-- 4*. ТРАНЗАКЦИЯ С COMMIT: Возврат денег: платёж становится refunded, подписка становится cancelled.
BEGIN;
UPDATE payments
SET status = 'refunded'
WHERE payment_id = 298;
UPDATE course_subscriptions
SET status = 'cancelled' -- допущена ошибка, пройдет ROLLBACK
WHERE subscr_id = (SELECT subscr_id FROM payments WHERE payment_id = 298);
COMMIT;

-- 5. ПРЕДСТАВЛЕНИЕ: Курсы преподавателя: число уроков, число активных студентов, выручка
CREATE OR REPLACE VIEW teacher_courses_view AS
SELECT c.teacher_id,
       c.course_id,
       c.title                                AS course_title,
       COUNT(DISTINCT l.lesson_id)            AS lessons_count,
       COUNT(DISTINCT cs.student_id)          AS active_students,
       COALESCE((SELECT SUM(p.amount)
                 FROM course_subscriptions cs2
                          JOIN payments p ON p.subscr_id = cs2.subscr_id
                 WHERE cs2.course_id = c.course_id
                   AND p.status = 'paid'), 0) AS total_revenue
FROM courses c
         LEFT JOIN lessons l ON l.course_id = c.course_id
         LEFT JOIN course_subscriptions cs ON c.course_id = cs.course_id AND cs.status = 'active'
GROUP BY c.teacher_id, c.course_id, c.title
ORDER BY teacher_id;

-- 5*. Тестируем представление
SELECT *
FROM teacher_courses_view
WHERE teacher_id = 2;