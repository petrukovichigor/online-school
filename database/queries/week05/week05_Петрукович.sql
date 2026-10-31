--Каталог: курсы с названием категории и ФИО преподавателя, по категории и цене (главный экран студента)
SELECT categories.name                                  Category,
       courses.title                                    Course,
       teachers.first_name || ' ' || teachers.last_name Teacher,
       courses.price                                    Price
FROM courses
         JOIN categories ON categories.category_id = courses.category_id
         JOIN teachers ON teachers.teacher_id = courses.teacher_id
ORDER BY Category, Price DESC;

--История оплат студентов курс, сумма, статус платежа и статус подписки
SELECT students.first_name || ' ' || students.last_name Student,
       courses.title                                    Course,
       payments.amount                                  Amount,
       payments.status                                  Payment_Status,
       course_subscriptions.status                      Subscription_Status
FROM course_subscriptions
         JOIN students ON students.student_id = course_subscriptions.student_id
         JOIN courses ON courses.course_id = course_subscriptions.course_id
         LEFT JOIN payments ON payments.subscr_id = course_subscriptions.subscr_id
ORDER BY Student, Amount DESC;

--Студенты, которые не подписаны ни на один курс (для рассылки)
SELECT first_name || ' ' || last_name Student
FROM students
         LEFT JOIN course_subscriptions ON students.student_id = course_subscriptions.student_id
WHERE course_id IS NULL
ORDER BY Student;

--Все категории и все курсы, включая категории без курсов (проверка каталога)
SELECT categories.name Category, courses.title Course
FROM categories
         FULL JOIN courses ON categories.category_id = courses.category_id
ORDER BY Category, Course;

--Единый список всех пользователей с ролью «студент» или «преподаватель» (основа для входа в систему)
SELECT first_name || ' ' || last_name Student, 'Student' Role
FROM students
UNION
SELECT first_name || ' ' || last_name Teacher, 'Teacher' Role
FROM teachers
ORDER BY Role, Student;