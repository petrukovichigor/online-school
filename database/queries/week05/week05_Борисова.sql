--Непроверенные работы с именем студента, заданием, уроком и курсом
SELECT first_name, last_name, homeworks.description, lessons.title, courses.title
FROM homework_submissions
         JOIN students ON homework_submissions.student_id = students.student_id
    AND grade IS NULL
         JOIN homeworks ON homework_submissions.homework_id = homeworks.homework_id
         JOIN lessons ON homeworks.lesson_id = lessons.lesson_id
         JOIN courses ON lessons.course_id = courses.course_id
ORDER BY courses.title, lessons.title;

--Задания курса, которые активный студент x ещё не сдал
SELECT lessons.title, homeworks.description
FROM course_subscriptions
         JOIN lessons ON course_subscriptions.course_id = lessons.course_id
         JOIN homeworks ON lessons.lesson_id = homeworks.lesson_id
         LEFT JOIN homework_submissions ON course_subscriptions.student_id = homework_submissions.student_id
    AND homeworks.homework_id = homework_submissions.homework_id
WHERE course_subscriptions.student_id = :student_id
  AND homework_submissions.submission_id IS NULL
ORDER BY lessons.title;

--Все студенты и количество сданных ими работ, включая тех, кто не сдал ничего
SELECT first_name, last_name, COUNT(submission_id) AS submissions
FROM homework_submissions
         RIGHT JOIN students ON homework_submissions.student_id = students.student_id
GROUP BY students.student_id
ORDER BY submissions DESC;

--Журнал оценок студента x: курс, урок, задание, оценка (экран «Мои оценки»)
SELECT courses.title, lessons.title, homeworks.description, grade
FROM homework_submissions
         JOIN homeworks ON homework_submissions.homework_id = homeworks.homework_id
         JOIN lessons ON homeworks.lesson_id = lessons.lesson_id
         JOIN courses ON lessons.course_id = courses.course_id
WHERE student_id = :student_id
  AND grade IS NOT NULL
ORDER BY courses.title, lessons.lesson_id;

--Студенты с активной подпиской, не сдавшие ни одной работы (отстающие)
SELECT students.first_name, students.last_name
FROM students
         JOIN course_subscriptions ON course_subscriptions.student_id = students.student_id
WHERE course_subscriptions.status = 'active'
EXCEPT
SELECT students.first_name, students.last_name
FROM students
         JOIN homework_submissions ON students.student_id = homework_submissions.student_id;
