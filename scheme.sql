CREATE TABLE "students"(
    "student_id" SERIAL NOT NULL,
    "first_name" VARCHAR(50) NOT NULL,
    "last_name" VARCHAR(50) NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "password_hash" VARCHAR(60) NOT NULL,
    "phone_number" VARCHAR(13) NULL
);
ALTER TABLE
    "students" ADD PRIMARY KEY("student_id");
ALTER TABLE
    "students" ADD CONSTRAINT "students_email_unique" UNIQUE("email");
CREATE TABLE "teachers"(
    "teacher_id" SERIAL NOT NULL,
    "first_name" VARCHAR(50) NOT NULL,
    "last_name" VARCHAR(50) NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "password_hash" VARCHAR(60) NOT NULL,
    "phone_number" VARCHAR(13) NULL,
    "salary" DECIMAL(10, 2) NULL
);
ALTER TABLE
    "teachers" ADD PRIMARY KEY("teacher_id");
ALTER TABLE
    "teachers" ADD CONSTRAINT "teachers_email_unique" UNIQUE("email");
CREATE TABLE "courses"(
    "course_id" SERIAL NOT NULL,
    "title" VARCHAR(150) NOT NULL,
    "description" TEXT NULL,
    "price" DECIMAL(10, 2) NOT NULL,
    "category_id" INTEGER NOT NULL,
    "teacher_id" INTEGER NOT NULL
);
ALTER TABLE
    "courses" ADD PRIMARY KEY("course_id");
CREATE TABLE "lessons"(
    "lesson_id" SERIAL NOT NULL,
    "position" INTEGER NOT NULL,
    "course_id" INTEGER NOT NULL,
    "title" VARCHAR(150) NOT NULL,
    "video_url" VARCHAR(500) NOT NULL
);
ALTER TABLE
    "lessons" ADD PRIMARY KEY("lesson_id");
CREATE TABLE "course_subscriptions"(
    "subscr_id" SERIAL NOT NULL,
    "student_id" INTEGER NOT NULL,
    "course_id" INTEGER NOT NULL,
    "status" VARCHAR(10) NOT NULL DEFAULT 'pending'
);
ALTER TABLE
    "course_subscriptions" ADD CONSTRAINT "course_subscriptions_student_id_course_id_unique" UNIQUE("student_id", "course_id");
ALTER TABLE
    "course_subscriptions" ADD PRIMARY KEY("subscr_id");
CREATE TABLE "homeworks"(
    "homework_id" SERIAL NOT NULL,
    "lesson_id" INTEGER NOT NULL,
    "description" TEXT NOT NULL
);
ALTER TABLE
    "homeworks" ADD PRIMARY KEY("homework_id");
CREATE TABLE "payments"(
    "payment_id" SERIAL NOT NULL,
    "subscr_id" INTEGER NOT NULL,
    "amount" DECIMAL(10, 2) NOT NULL,
    "status" VARCHAR(10) NOT NULL DEFAULT 'pending',
    "transaction_id" VARCHAR(36) NULL
);
ALTER TABLE
    "payments" ADD PRIMARY KEY("payment_id");
ALTER TABLE
    "payments" ADD CONSTRAINT "payments_subscr_id_unique" UNIQUE("subscr_id");
ALTER TABLE
    "payments" ADD CONSTRAINT "payments_transaction_id_unique" UNIQUE("transaction_id");
CREATE TABLE "homework_submissions"(
    "submission_id" SERIAL NOT NULL,
    "homework_id" INTEGER NOT NULL,
    "student_id" INTEGER NOT NULL,
    "file_url" VARCHAR(500) NOT NULL,
    "grade" INTEGER NULL
);
ALTER TABLE
    "homework_submissions" ADD CONSTRAINT "homework_submissions_homework_id_student_id_unique" UNIQUE("homework_id", "student_id");
ALTER TABLE
    "homework_submissions" ADD PRIMARY KEY("submission_id");
CREATE TABLE "categories"(
    "category_id" SERIAL NOT NULL,
    "name" VARCHAR(50) NOT NULL
);
ALTER TABLE
    "categories" ADD PRIMARY KEY("category_id");
ALTER TABLE
    "categories" ADD CONSTRAINT "categories_name_unique" UNIQUE("name");
ALTER TABLE
    "lessons" ADD CONSTRAINT "lessons_course_id_foreign" FOREIGN KEY("course_id") REFERENCES "courses"("course_id");
ALTER TABLE
    "homeworks" ADD CONSTRAINT "homeworks_lesson_id_foreign" FOREIGN KEY("lesson_id") REFERENCES "lessons"("lesson_id");
ALTER TABLE
    "course_subscriptions" ADD CONSTRAINT "course_subscriptions_student_id_foreign" FOREIGN KEY("student_id") REFERENCES "students"("student_id");
ALTER TABLE
    "courses" ADD CONSTRAINT "courses_teacher_id_foreign" FOREIGN KEY("teacher_id") REFERENCES "teachers"("teacher_id");
ALTER TABLE
    "homework_submissions" ADD CONSTRAINT "homework_submissions_student_id_foreign" FOREIGN KEY("student_id") REFERENCES "students"("student_id");
ALTER TABLE
    "course_subscriptions" ADD CONSTRAINT "course_subscriptions_course_id_foreign" FOREIGN KEY("course_id") REFERENCES "courses"("course_id");
ALTER TABLE
    "homework_submissions" ADD CONSTRAINT "homework_submissions_homework_id_foreign" FOREIGN KEY("homework_id") REFERENCES "homeworks"("homework_id");
ALTER TABLE
    "payments" ADD CONSTRAINT "payments_subscr_id_foreign" FOREIGN KEY("subscr_id") REFERENCES "course_subscriptions"("subscr_id");
ALTER TABLE
    "courses" ADD CONSTRAINT "courses_category_id_foreign" FOREIGN KEY("category_id") REFERENCES "categories"("category_id");