-- Обновление записей в таблицах

UPDATE teams
SET description = 'Отдел разработки'
WHERE id = 3;

UPDATE teams
SET description = 'Отдел маркетинга'
WHERE id = 4;

UPDATE users
SET first_name = 'Иван'
WHERE last_name = 'Петров';

UPDATE users
SET first_name = 'Елена'
WHERE last_name = 'Сидорова';

UPDATE deals
SET amount = 150000.00
WHERE id = 1;

-- Удаление записей из таблиц

DELETE FROM teams
WHERE id = 3;

DELETE FROM deals
WHERE id = 1;

DELETE FROM contacts
WHERE id = 1;

DELETE FROM clients
WHERE id = 1;

-- Выборка данных из таблиц

SELECT * FROM teams;

-- Выборка уникальных значений
SELECT DISTINCT role_id FROM users;

-- выборка с условием
SELECT * FROM users
WHERE role_id = 2;

-- выборка с условием
SELECT * FROM users
WHERE role_id = 2 AND team_id = 1;

-- выборка с условием
SELECT * FROM users
WHERE role_id IN (1, 2);

-- выборка с условием
SELECT * FROM users
WHERE role_id IN (1, 2) AND team_id = 1;

SELECT * FROM deals
WHERE amount > 100000;

-- выборка с условием
SELECT * FROM users
WHERE role_id = 2 AND NOT team_id = 1;

SELECT * FROM users
WHERE team_id IS NULL;

SELECT * FROM users
WHERE team_id IS NOT NULL;

SELECT * FROM products
WHERE currency = 'USD';

SELECT * FROM products
WHERE NOT is_active;

SELECT * FROM products
WHERE is_active = TRUE;

SELECT * FROM products
WHERE is_active = TRUE AND currency = 'USD';

-- LIKE

SELECT * FROM users
WHERE first_name LIKE 'И%';

SELECT * FROM users
WHERE first_name LIKE 'И__н';

SELECT SUBSTRING(first_name, 1, 2)
FROM users;

SELECT LEFT(first_name, 2)
FROM users;

SELECT RIGHT(first_name, 2)
FROM users;

--select into

SELECT * INTO test FROM users;

SELECT * INTO test2 FROM deals
WHERE amount > 20000;

-- Запросы с JOIN

SELECT users.first_name, users.last_name, teams.description
FROM users
JOIN teams
ON users.team_id = teams.id;

SELECT users.first_name, users.last_name, teams.description
FROM users
INNER JOIN teams
ON users.team_id = teams.id;


SELECT users.first_name, users.last_name, teams.description
FROM users
LEFT JOIN teams
ON users.team_id = teams.id;


SELECT users.first_name, users.last_name, teams.description
FROM users
RIGHT JOIN teams
ON users.team_id = teams.id;

SELECT users.first_name, users.last_name, teams.description
FROM users
FULL JOIN teams
ON users.team_id = teams.id;

SELECT users.first_name, users.last_name, teams.description
FROM users
CROSS JOIN teams;


SELECT users.first_name, users.last_name, teams.description
FROM users first_name
JOIN users last_name
ON users.team_id = teams.id;


-- Группировка

SELECT * FROM teams
GROUP BY description;

SELECT team_id, COUNT(*)
FROM users
GROUP BY team_id;

SELECT team_id, COUNT(*)
FROM users
ORDER BY role_id;

SELECT team_id, COUNT(*)
FROM users
ORDER BY role_id DESC;

SELECT * FROM users
WHERE team_id = 1
GROUP BY team_id LIMIT 1;

SELECT * FROM users
WHERE team_id = 1
GROUP BY team_id LIMIT 1 OFFSET 1;

-- Примеры запросов с UNION, EXCEPT, INTERSECT

-- UNION: объединение результатов двух запросов (без дубликатов)
-- Получение всех уникальных имен и фамилий из таблицы users и контактов
SELECT first_name, last_name
FROM users
UNION
SELECT first_name, last_name
FROM contacts;

-- UNION ALL: объединение результатов двух запросов (с дубликатами)
-- Получение всех имен и фамилий из таблицы users и контактов, включая дубликаты
SELECT first_name, last_name
FROM users
UNION ALL
SELECT first_name, last_name
FROM contacts;

-- EXCEPT: возвращает строки из первого запроса, которых нет во втором
-- Найти пользователей, которые не являются контактами клиентов
SELECT first_name, last_name
FROM users
EXCEPT
SELECT first_name, last_name
FROM contacts;

-- INTERSECT: возвращает только те строки, которые есть в обоих запросах
-- Найти пользователей, которые также являются контактами клиентов
SELECT first_name, last_name
FROM users
INTERSECT
SELECT first_name, last_name
FROM contacts;

-- Примеры запросов с GROUP_CONCAT и другими функциями

-- GROUP_CONCAT: объединение значений в строку с разделителем
-- Получение списка всех контактов для каждого клиента
SELECT
    c.company_name,
    STRING_AGG(ct.first_name || ' ' || ct.last_name, ', ') AS contacts_list
FROM clients c
LEFT JOIN contacts ct ON c.id = ct.client_id
GROUP BY c.company_name;

-- Пример с несколькими агрегатными функциями
-- Анализ сделок по клиентам
SELECT
    c.company_name,
    COUNT(d.id) AS deals_count,
    SUM(d.amount) AS total_amount,
    AVG(d.amount) AS avg_amount,
    MIN(d.amount) AS min_amount,
    MAX(d.amount) AS max_amount,
    STRING_AGG(d.title, '; ') AS deals_list
FROM clients c
LEFT JOIN deals d ON c.id = d.client_id
GROUP BY c.company_name;

-- Примеры запросов с WITH (CTE)

-- Рекурсивный CTE для построения иерархии задач
WITH RECURSIVE task_hierarchy AS (
    -- Базовый запрос
    SELECT
        id,
        title,
        project_manager_id,
        1 AS level
    FROM tasks
    WHERE project_manager_id IS NULL

    UNION ALL

    -- Рекурсивная часть
    SELECT
        t.id,
        t.title,
        t.project_manager_id,
        th.level + 1
    FROM tasks t
    JOIN task_hierarchy th ON t.project_manager_id = th.id
)
SELECT * FROM task_hierarchy
ORDER BY level, id;

-- CTE для анализа воронки продаж
WITH sales_funnel AS (
    SELECT
        stage,
        COUNT(*) AS deals_count,
        SUM(amount) AS total_amount
    FROM deals
    GROUP BY stage
),
stage_percentages AS (
    SELECT
        stage,
        deals_count,
        total_amount,
        ROUND(deals_count * 100.0 / SUM(deals_count) OVER (), 2) AS deals_percentage,
        ROUND(total_amount * 100.0 / SUM(total_amount) OVER (), 2) AS amount_percentage
    FROM sales_funnel
)
SELECT * FROM stage_percentages
ORDER BY
    CASE stage
        WHEN 'lead' THEN 1
        WHEN 'proposal' THEN 2
        WHEN 'negotiation' THEN 3
        WHEN 'won' THEN 4
        WHEN 'lost' THEN 5
    END;

-- CTE для анализа эффективности менеджеров
WITH manager_stats AS (
    SELECT
        u.id,
        u.first_name,
        u.last_name,
        COUNT(d.id) AS total_deals,
        SUM(CASE WHEN d.stage = 'won' THEN 1 ELSE 0 END) AS won_deals,
        SUM(CASE WHEN d.stage = 'won' THEN d.amount ELSE 0 END) AS total_revenue
    FROM users u
    LEFT JOIN deals d ON u.id = d.assigned_to
    WHERE u.role_id = 3  -- менеджеры по продажам
    GROUP BY u.id, u.first_name, u.last_name
)
SELECT
    names,
    total_deals,
    won_deals,
    total_revenue,
    ROUND(won_deals * 100.0 / NULLIF(total_deals, 0), 2) AS win_rate,
    ROUND(total_revenue / NULLIF(won_deals, 0), 2) AS avg_deal_size
FROM manager_stats
ORDER BY total_revenue DESC;
