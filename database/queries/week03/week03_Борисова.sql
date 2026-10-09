-- Курсы, в названии которых есть «English» или «Design»
SELECT *
FROM courses
WHERE title LIKE '%English%' OR title LIKE '%Design%';

-- Непроверенные работы (очередь проверки для преподавателя)
SELECT *
FROM homework_submissions
WHERE grade IS NULL;

-- Работы с оценкой от 8 до 10, от лучших к худшим
SELECT *
FROM homework_submissions
WHERE grade BETWEEN 8 AND 10
ORDER BY grade DESC;

-- Курсы категорий "Дизайн" и "Программирование" дороже 100 руб
SELECT name, title, description
FROM courses
JOIN categories ON courses.category_id = categories.category_id
WHERE categories.name IN ('Programming', 'Design')
  AND courses.price > 100
ORDER BY name;


-- ДЗ по которым уже есть хотя бы одна сданная работа, без повторов
-- На данный момент в нашей БД все дз сделаны
SELECT DISTINCT hs.homework_id, h.description
FROM homework_submissions hs
JOIN homeworks h ON h.homework_id = hs.homework_id
ORDER BY hs.homework_id;
