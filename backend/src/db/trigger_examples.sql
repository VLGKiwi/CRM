-- ============================================================================
-- ПРИМЕРЫ РАБОТЫ ТРИГГЕРОВ
-- ============================================================================

-- 1. Триггер автоматического создания задач при создании сделки
-- Создаем новую сделку, что автоматически создаст связанные задачи
INSERT INTO deals (
    client_id,
    title,
    amount,
    currency,
    stage,
    created_by,
    assigned_to
) VALUES (
    1,  -- ID существующего клиента
    'New Software Implementation',
    75000,
    'USD',
    'Initial Contact',
    'e89b2fdd-4f16-4f32-8e6a-0c29c1a8e6e5'::UUID,  -- ID создателя
    'e89b2fdd-4f16-4f32-8e6a-0c29c1a8e6e5'::UUID   -- ID ответственного
);

-- Проверяем созданные задачи
SELECT t.title, t.description, t.priority, t.status, t.due_date
FROM tasks t
WHERE t.deal_id = (SELECT MAX(id) FROM deals)
ORDER BY t.created_at;

-- ============================================================================
-- ПРИМЕР РАБОТЫ ТРИГГЕРА АВТОМАТИЧЕСКОГО СОЗДАНИЯ ЗАДАЧ
-- ============================================================================

-- 1. Сначала создадим тестового клиента
INSERT INTO clients (
    company_name,
    industry,
    status
) VALUES (
    'Test Company LLC',
    'Technology',
    'Active'
)
RETURNING id;

-- 2. Проверяем текущее количество задач
SELECT COUNT(*) as tasks_before FROM tasks;

-- 3. Создаем новую сделку (это автоматически запустит триггер)
INSERT INTO deals (
    client_id,
    title,
    amount,
    currency,
    stage,
    probability,
    expected_close_date,
    created_by,
    assigned_to
) VALUES (
    (SELECT id FROM clients WHERE company_name = 'Test Company LLC' ORDER BY id DESC LIMIT 1),
    'New Enterprise Project',
    150000,
    'USD',
    'Initial Contact',
    20,
    CURRENT_DATE + INTERVAL '30 days',
    (SELECT id FROM users WHERE role_id = 1 LIMIT 1),  -- ID роли менеджера
    (SELECT id FROM users WHERE role_id = 2 LIMIT 1)   -- ID роли продажника
)
RETURNING id;

-- 4. Проверяем созданные задачи
SELECT
    t.title,
    t.description,
    t.priority,
    t.status,
    t.due_date,
    u.first_name || ' ' || u.last_name as assigned_to,
    d.title as deal_title,
    c.company_name as client
FROM tasks t
JOIN users u ON t.developer_id = u.id
JOIN users u2 ON t.created_by = u2.id
WHERE t.created_by = (
    SELECT created_by
    FROM deals
    WHERE title = 'New Enterprise Project'
)
AND t.created_at >= (
    SELECT created_at
    FROM deals
    WHERE title = 'New Enterprise Project'
)
ORDER BY t.due_date;

-- 5. Проверяем общее количество задач после
SELECT COUNT(*) as tasks_after FROM tasks;

-- 6. Проверяем статистику по созданным задачам
SELECT
    priority,
    status,
    COUNT(*) as tasks_count,
    MIN(due_date) as earliest_due_date,
    MAX(due_date) as latest_due_date
FROM tasks
WHERE created_by = (
    SELECT created_by
    FROM deals
    WHERE title = 'New Enterprise Project'
)
AND created_at >= (
    SELECT created_at
    FROM deals
    WHERE title = 'New Enterprise Project'
)
GROUP BY priority, status
ORDER BY priority, status;

-- 7. Проверяем корректность назначения исполнителей
SELECT DISTINCT
    u.first_name || ' ' || u.last_name as user_name,
    u.role_id,
    COUNT(t.id) as assigned_tasks
FROM users u
JOIN tasks t ON u.id = t.developer_id
WHERE t.created_by = (
    SELECT created_by
    FROM deals
    WHERE title = 'New Enterprise Project'
)
AND t.created_at >= (
    SELECT created_at
    FROM deals
    WHERE title = 'New Enterprise Project'
)
GROUP BY u.id, u.first_name, u.last_name, u.role_id;

-- 8. Проверяем связь с активностями
SELECT
    a.type,
    a.subject,
    a.description,
    a.created_at,
    u.first_name || ' ' || u.last_name as created_by
FROM activities a
JOIN users u ON a.created_by = u.id
WHERE a.deal_id = (
    SELECT id
    FROM deals
    WHERE title = 'New Enterprise Project'
)
ORDER BY a.created_at DESC;
