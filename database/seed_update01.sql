BEGIN;

INSERT INTO "teachers" ("teacher_id", "first_name", "last_name", "email", "password_hash", "phone_number", "salary") VALUES
    (11, 'Andrei', 'Kavaliou', 'andrei.kavaliou@school.by', '$2b$12$GtxavrYRaH0iuxT8nDQIl.iavxSXHfqp6GLLPGrzq7CHoe0K1AmMe', '+375291234567', 2200.00),
    (12, 'Katsiaryna', 'Paulovich', 'katsiaryna.paulovich@school.by', '$2b$12$GtxavrYRaH0iuxT8nDQIl.iavxSXHfqp6GLLPGrzq7CHoe0K1AmMe', '+375292345678', 2400.00),
    (13, 'Dzmitry', 'Marozau', 'dzmitry.marozau@school.by', '$2b$12$GtxavrYRaH0iuxT8nDQIl.iavxSXHfqp6GLLPGrzq7CHoe0K1AmMe', '+375293456789', 1900.00),
    (14, 'Volha', 'Tkachova', 'volha.tkachova@school.by', '$2b$12$GtxavrYRaH0iuxT8nDQIl.iavxSXHfqp6GLLPGrzq7CHoe0K1AmMe', '+375294567890', 2600.00),
    (15, 'Emil', 'Sincler', 'emil.sincler@school.by', '$2b$12$GtxavrYRaH0iuxT8nDQIl.iavxSXHfqp6GLLPGrzq7CHoe0K1AmMe', NULL, 1800.00);

INSERT INTO "courses" ("course_id", "title", "description", "price", "category_id", "teacher_id") VALUES
    (16, 'Advanced Python', 'Deep dive into Python: decorators, generators, async and testing.', 220.00, 1, 11),
    (17, 'Spanish for Beginners', 'Learn Spanish from scratch: alphabet, basic grammar and conversational skills.', 130.00, 2, 12),
    (18, '3D Modeling in Blender', 'Comprehensive guide to 3D modeling, texturing and lighting in Blender.', 200.00, 3, 13),
    (19, 'Content Marketing', 'How to create a content strategy, write engaging posts and measure results.', 140.00, 4, 14),
    (20, 'Startup Fundamentals', 'From idea to MVP: how to launch and scale your own business.', 180.00, 5, 15);

INSERT INTO "lessons" ("lesson_id", "position", "course_id", "title", "video_url") VALUES
    -- Course 16: Advanced Python
    (61, 1, 16, 'Decorators and Closures', 'https://www.youtube.com/watch?v=advanced_python_1'),
    (62, 2, 16, 'Generators and Iterators', 'https://www.youtube.com/watch?v=advanced_python_2'),
    (63, 3, 16, 'Async IO Basics', 'https://www.youtube.com/watch?v=advanced_python_3'),
    (64, 4, 16, 'Unit Testing with Pytest', 'https://www.youtube.com/watch?v=advanced_python_4'),
    -- Course 17: Spanish for Beginners
    (65, 1, 17, 'Spanish Alphabet and Sounds', 'https://www.youtube.com/watch?v=spanish_1'),
    (66, 2, 17, 'Greetings and Introductions', 'https://www.youtube.com/watch?v=spanish_2'),
    (67, 3, 17, 'Regular Verbs in Present Tense', 'https://www.youtube.com/watch?v=spanish_3'),
    (68, 4, 17, 'Ordering Food and Drinks', 'https://www.youtube.com/watch?v=spanish_4'),
    -- Course 18: 3D Modeling in Blender
    (69, 1, 18, 'Blender Interface and Navigation', 'https://www.youtube.com/watch?v=blender_1'),
    (70, 2, 18, 'Basic Mesh Modeling', 'https://www.youtube.com/watch?v=blender_2'),
    (71, 3, 18, 'Materials and Textures', 'https://www.youtube.com/watch?v=blender_3'),
    (72, 4, 18, 'Lighting and Rendering', 'https://www.youtube.com/watch?v=blender_4'),
    -- Course 19: Content Marketing
    (73, 1, 19, 'Building a Content Strategy', 'https://www.youtube.com/watch?v=content_1'),
    (74, 2, 19, 'Writing Blog Posts and Articles', 'https://www.youtube.com/watch?v=content_2'),
    (75, 3, 19, 'Video Content Creation', 'https://www.youtube.com/watch?v=content_3'),
    (76, 4, 19, 'SEO for Content Writers', 'https://www.youtube.com/watch?v=content_4'),
    -- Course 20: Startup Fundamentals
    (77, 1, 20, 'Idea Generation and Validation', 'https://www.youtube.com/watch?v=startup_1'),
    (78, 2, 20, 'Building an MVP', 'https://www.youtube.com/watch?v=startup_2'),
    (79, 3, 20, 'Finding Investors and Funding', 'https://www.youtube.com/watch?v=startup_3'),
    (80, 4, 20, 'Scaling and Team Building', 'https://www.youtube.com/watch?v=startup_4');

INSERT INTO "homeworks" ("homework_id", "lesson_id", "description") VALUES
    (31, 63, 'Complete the practice task for the lesson "Async IO Basics" and upload your file.'),
    (32, 64, 'Complete the practice task for the lesson "Unit Testing with Pytest" and upload your file.'),
    (33, 67, 'Complete the practice task for the lesson "Regular Verbs in Present Tense" and upload your file.'),
    (34, 68, 'Complete the practice task for the lesson "Ordering Food and Drinks" and upload your file.'),
    (35, 71, 'Complete the practice task for the lesson "Materials and Textures" and upload your file.'),
    (36, 72, 'Complete the practice task for the lesson "Lighting and Rendering" and upload your file.'),
    (37, 75, 'Complete the practice task for the lesson "Video Content Creation" and upload your file.'),
    (38, 76, 'Complete the practice task for the lesson "SEO for Content Writers" and upload your file.'),
    (39, 79, 'Complete the practice task for the lesson "Finding Investors and Funding" and upload your file.'),
    (40, 80, 'Complete the practice task for the lesson "Scaling and Team Building" and upload your file.');

INSERT INTO "course_subscriptions" ("subscr_id", "student_id", "course_id", "status") VALUES
    (111, 1, 16, 'active'),
    (112, 2, 16, 'active'),
    (113, 3, 17, 'pending'),
    (114, 4, 17, 'active'),
    (115, 5, 18, 'active'),
    (116, 6, 18, 'active'),
    (117, 7, 19, 'active'),
    (118, 8, 19, 'cancelled'),
    (119, 9, 20, 'active'),
    (120, 10, 20, 'active'),
    (121, 11, 16, 'active'),
    (122, 12, 17, 'active'),
    (123, 13, 18, 'pending'),
    (124, 14, 19, 'active'),
    (125, 15, 20, 'active'),
    (126, 16, 16, 'active'),
    (127, 17, 17, 'cancelled'),
    (128, 18, 18, 'active'),
    (129, 19, 19, 'active'),
    (130, 20, 20, 'active');

INSERT INTO "payments" ("payment_id", "subscr_id", "amount", "status", "transaction_id") VALUES
    (111, 111, 220.00, 'paid', 'TXN-9000000001'),
    (112, 112, 220.00, 'paid', 'TXN-9000000002'),
    (113, 113, 130.00, 'pending', NULL),
    (114, 114, 130.00, 'paid', 'TXN-9000000003'),
    (115, 115, 200.00, 'paid', 'TXN-9000000004'),
    (116, 116, 200.00, 'paid', 'TXN-9000000005'),
    (117, 117, 140.00, 'paid', 'TXN-9000000006'),
    (118, 118, 140.00, 'refunded', 'TXN-9000000007'),
    (119, 119, 180.00, 'paid', 'TXN-9000000008'),
    (120, 120, 180.00, 'paid', 'TXN-9000000009'),
    (121, 121, 220.00, 'paid', 'TXN-9000000010'),
    (122, 122, 130.00, 'paid', 'TXN-9000000011'),
    (123, 123, 200.00, 'pending', NULL),
    (124, 124, 140.00, 'paid', 'TXN-9000000012'),
    (125, 125, 180.00, 'paid', 'TXN-9000000013'),
    (126, 126, 220.00, 'paid', 'TXN-9000000014'),
    (127, 127, 130.00, 'refunded', 'TXN-9000000015'),
    (128, 128, 200.00, 'paid', 'TXN-9000000016'),
    (129, 129, 140.00, 'paid', 'TXN-9000000017'),
    (130, 130, 180.00, 'paid', 'TXN-9000000018');

INSERT INTO "homework_submissions" ("submission_id", "homework_id", "student_id", "file_url", "grade") VALUES
    -- Course 16 (Students: 1, 2, 11, 16)
    (124, 31, 1, 'https://drive.google.com/file/d/new_sub_1/view', 9),
    (125, 32, 1, 'https://drive.google.com/file/d/new_sub_2/view', 8),
    (126, 31, 2, 'https://drive.google.com/file/d/new_sub_3/view', 7),
    (127, 32, 2, 'https://drive.google.com/file/d/new_sub_4/view', NULL),
    (128, 31, 11, 'https://drive.google.com/file/d/new_sub_5/view', 8),
    (129, 32, 11, 'https://drive.google.com/file/d/new_sub_6/view', 9),
    (130, 31, 16, 'https://drive.google.com/file/d/new_sub_7/view', 10),
    (131, 32, 16, 'https://drive.google.com/file/d/new_sub_8/view', 7),
    
    -- Course 17 (Students: 3, 4, 12, 17)
    (132, 33, 3, 'https://drive.google.com/file/d/new_sub_9/view', 6),
    (133, 34, 3, 'https://drive.google.com/file/d/new_sub_10/view', 9),
    (134, 33, 4, 'https://drive.google.com/file/d/new_sub_11/view', 10),
    (135, 34, 4, 'https://drive.google.com/file/d/new_sub_12/view', 8),
    (136, 33, 12, 'https://drive.google.com/file/d/new_sub_13/view', 7),
    (137, 34, 12, 'https://drive.google.com/file/d/new_sub_14/view', NULL),
    (138, 33, 17, 'https://drive.google.com/file/d/new_sub_15/view', 9),
    
    -- Course 18 (Students: 5, 6, 13, 18)
    (139, 35, 5, 'https://drive.google.com/file/d/new_sub_16/view', 8),
    (140, 36, 5, 'https://drive.google.com/file/d/new_sub_17/view', 9),
    (141, 35, 6, 'https://drive.google.com/file/d/new_sub_18/view', 10),
    (142, 36, 6, 'https://drive.google.com/file/d/new_sub_19/view', 6),
    (143, 35, 13, 'https://drive.google.com/file/d/new_sub_20/view', NULL),
    (144, 35, 18, 'https://drive.google.com/file/d/new_sub_21/view', 7),
    
    -- Course 19 (Students: 7, 9, 14, 19)
    (145, 37, 7, 'https://drive.google.com/file/d/new_sub_22/view', 8),
    (146, 38, 7, 'https://drive.google.com/file/d/new_sub_23/view', 9),
    (147, 37, 9, 'https://drive.google.com/file/d/new_sub_24/view', 10),
    (148, 38, 9, 'https://drive.google.com/file/d/new_sub_25/view', 7),
    (149, 37, 14, 'https://drive.google.com/file/d/new_sub_26/view', 8),
    (150, 38, 14, 'https://drive.google.com/file/d/new_sub_27/view', 6),
    (151, 37, 19, 'https://drive.google.com/file/d/new_sub_28/view', 9),
    
    -- Course 20 (Students: 10, 15, 20)
    (152, 39, 10, 'https://drive.google.com/file/d/new_sub_29/view', 8),
    (153, 40, 10, 'https://drive.google.com/file/d/new_sub_30/view', 9),
    (154, 39, 15, 'https://drive.google.com/file/d/new_sub_31/view', 7),
    (155, 40, 15, 'https://drive.google.com/file/d/new_sub_32/view', 10),
    (156, 39, 20, 'https://drive.google.com/file/d/new_sub_33/view', 9),
    (157, 40, 20, 'https://drive.google.com/file/d/new_sub_34/view', 8);

SELECT setval(pg_get_serial_sequence('teachers', 'teacher_id'), (SELECT MAX("teacher_id") FROM "teachers"));
SELECT setval(pg_get_serial_sequence('courses', 'course_id'), (SELECT MAX("course_id") FROM "courses"));
SELECT setval(pg_get_serial_sequence('lessons', 'lesson_id'), (SELECT MAX("lesson_id") FROM "lessons"));
SELECT setval(pg_get_serial_sequence('homeworks', 'homework_id'), (SELECT MAX("homework_id") FROM "homeworks"));
SELECT setval(pg_get_serial_sequence('course_subscriptions', 'subscr_id'), (SELECT MAX("subscr_id") FROM "course_subscriptions"));
SELECT setval(pg_get_serial_sequence('payments', 'payment_id'), (SELECT MAX("payment_id") FROM "payments"));
SELECT setval(pg_get_serial_sequence('homework_submissions', 'submission_id'), (SELECT MAX("submission_id") FROM "homework_submissions"));

COMMIT;