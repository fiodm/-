
-- Лабораторна робота №4
-- Тема: Аналітичні SQL-запити (OLAP)
-- База даних: university_db
-- PostgreSQL

-- 1. Агрегація: загальна кількість студентів
SELECT COUNT(*) AS total_students
FROM students;

-- 2. Агрегація: кількість студентів у кожній групі
SELECT
    g.group_name,
    COUNT(s.student_id) AS student_count
FROM study_groups AS g
LEFT JOIN students AS s
    ON g.group_id = s.group_id
GROUP BY g.group_id, g.group_name
ORDER BY g.group_name;

-- 3. Агрегація: групи, у яких є хоча б один студент
SELECT
    g.group_name,
    COUNT(s.student_id) AS student_count
FROM study_groups AS g
LEFT JOIN students AS s
    ON g.group_id = s.group_id
GROUP BY g.group_id, g.group_name
HAVING COUNT(s.student_id) >= 1
ORDER BY student_count DESC;

-- 4. Агрегація: статистика кількості студентів
SELECT
    MIN(group_size) AS min_students,
    MAX(group_size) AS max_students,
    ROUND(AVG(group_size), 2) AS avg_students,
    SUM(group_size) AS total_students
FROM (
    SELECT COUNT(s.student_id) AS group_size
    FROM study_groups AS g
    LEFT JOIN students AS s
        ON g.group_id = s.group_id
    GROUP BY g.group_id
) AS group_statistics;

-- 5. INNER JOIN: студенти та їхні групи
SELECT
    s.student_id,
    s.first_name,
    s.last_name,
    g.group_name
FROM students AS s
INNER JOIN study_groups AS g
    ON s.group_id = g.group_id
ORDER BY s.student_id;

-- 6. LEFT JOIN: усі навчальні групи та студенти
SELECT
    g.group_name,
    s.first_name,
    s.last_name
FROM study_groups AS g
LEFT JOIN students AS s
    ON g.group_id = s.group_id
ORDER BY g.group_name;

-- 7. RIGHT JOIN: студенти та всі навчальні групи
SELECT
    g.group_name,
    s.first_name,
    s.last_name
FROM students AS s
RIGHT JOIN study_groups AS g
    ON s.group_id = g.group_id
ORDER BY g.group_name;

-- 8. Підзапит у WHERE:
-- студенти навчальної групи ІПЗ-21
SELECT
    first_name,
    last_name,
    email
FROM students
WHERE group_id = (
    SELECT group_id
    FROM study_groups
    WHERE group_name = 'ІПЗ-21'
);

-- 9. Корельований підзапит у SELECT:
-- кількість студентів у кожній групі
SELECT
    g.group_name,
    (
        SELECT COUNT(*)
        FROM students AS s
        WHERE s.group_id = g.group_id
    ) AS student_count
FROM study_groups AS g
ORDER BY g.group_name;

-- 10. Підзапит у HAVING:
-- групи, у яких кількість студентів
-- не менша за середню
SELECT
    g.group_name,
    COUNT(s.student_id) AS student_count
FROM study_groups AS g
LEFT JOIN students AS s
    ON g.group_id = s.group_id
GROUP BY g.group_id, g.group_name
HAVING COUNT(s.student_id) >= (
    SELECT AVG(group_size)
    FROM (
        SELECT COUNT(s2.student_id) AS group_size
        FROM study_groups AS g2
        LEFT JOIN students AS s2
            ON g2.group_id = s2.group_id
        GROUP BY g2.group_id
    ) AS sizes
)
ORDER BY student_count DESC, g.group_name;

-- 11. Додаткова перевірка кількості записів
SELECT 'Навчальні групи' AS table_name, COUNT(*) AS total
FROM study_groups
UNION ALL
SELECT 'Студенти', COUNT(*)
FROM students
UNION ALL
SELECT 'Викладачі', COUNT(*)
FROM teachers;
