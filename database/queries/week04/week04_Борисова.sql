--Средняя оценка по каждой домашке, только проверенные работы, от лёгких к сложным
SELECT homework_id, AVG(grade) average_grade
FROM homework_submissions
WHERE grade IS NOT NULL
GROUP BY homework_id
ORDER BY average_grade DESC;

--Для каждого студента: сколько работ сдал, сколько проверено и сумма баллов (рейтинг)
SELECT student_id, COUNT(submission_id) submissed_homeworks, COUNT(grade) checked_homeworks, SUM(grade) rating
FROM homework_submissions
GROUP BY student_id
ORDER BY rating DESC;

--Задания со средней оценкой ниже 6 (слишком сложные задания)
SELECT homework_id hard_homeworks, AVG(grade) average_mark
FROM homework_submissions
GROUP BY homework_id
HAVING AVG(grade) < 6
ORDER BY average_mark DESC;

--Лучшая и худшая оценка каждого студента
SELECT student_id, MIN(grade) worst_grade, MAX(grade) best_grade
FROM homework_submissions
GROUP BY student_id
ORDER BY student_id;

--Сколько раз каждая оценка поставлена по каждому заданию (распределение оценок)
SELECT homework_id, grade, COUNT(grade)
FROM homework_submissions
WHERE grade IS NOT NULL
GROUP BY homework_id, grade
ORDER BY homework_id, grade DESC;
