-- ============================================================================
-- ТРИГГЕР СОЗДАНИЯ ЗАДАЧ ДЛЯ СДЕЛКИ
-- ============================================================================

-- Функция для создания автоматических задач при создании сделки
CREATE OR REPLACE FUNCTION create_default_deal_tasks()
RETURNS TRIGGER AS $$
DECLARE
    HIGH_PRIORITY integer := 1;
    MEDIUM_PRIORITY integer := 2;
    LOW_PRIORITY integer := 3;
BEGIN
    -- Создаем задачу для первичного контакта
    INSERT INTO tasks (
        title,
        description,
        priority,
        status,
        due_date,
        created_by,
        developer_id
    ) VALUES (
        'Первичный контакт с клиентом по сделке ' || NEW.title,
        'Провести первичную встречу с клиентом для обсуждения деталей сделки',
        HIGH_PRIORITY,
        'New',
        CURRENT_DATE + INTERVAL '2 days',
        NEW.created_by,
        NEW.assigned_to
    );

    -- Создаем задачу для подготовки коммерческого предложения
    INSERT INTO tasks (
        title,
        description,
        priority,
        status,
        due_date,
        created_by,
        developer_id
    ) VALUES (
        'Подготовить КП для ' || NEW.title,
        'Разработать и отправить коммерческое предложение клиенту',
        HIGH_PRIORITY,
        'New',
        CURRENT_DATE + INTERVAL '5 days',
        NEW.created_by,
        NEW.assigned_to
    );

    -- Создаем задачу для follow-up
    INSERT INTO tasks (
        title,
        description,
        priority,
        status,
        due_date,
        created_by,
        developer_id
    ) VALUES (
        'Follow-up по КП - ' || NEW.title,
        'Связаться с клиентом для получения обратной связи по коммерческому предложению',
        MEDIUM_PRIORITY,
        'New',
        CURRENT_DATE + INTERVAL '7 days',
        NEW.created_by,
        NEW.assigned_to
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Создаем триггер, который будет вызывать функцию после создания новой сделки
DROP TRIGGER IF EXISTS trg_create_deal_tasks ON deals;
CREATE TRIGGER trg_create_deal_tasks
    AFTER INSERT
    ON deals
    FOR EACH ROW
    EXECUTE FUNCTION create_default_deal_tasks();

-- ============================================================================
-- ПРИМЕР ЗАПУСКА ТРИГГЕРА
-- ============================================================================

-- Создаем тестового клиента
INSERT INTO clients (
    company_name,
    industry,
    status
) VALUES (
    'Тестовая Компания',
    'IT',
    'Active'
) RETURNING id;

-- Проверяем количество задач до создания сделки
SELECT COUNT(*) as tasks_before FROM tasks;

-- Создаем сделку, которая автоматически запустит триггер
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
    (SELECT id FROM clients WHERE company_name = 'Тестовая Компания'),
    'Тестовый проект автоматизации',
    100000,
    'RUB',
    'Initial Contact',
    20,
    CURRENT_DATE + INTERVAL '30 days',
    (SELECT id FROM users WHERE role_id = 1 LIMIT 1),  -- ID менеджера
    (SELECT id FROM users WHERE role_id = 2 LIMIT 1)   -- ID продажника
);

-- Проверяем созданные задачи
SELECT
    t.title,
    t.description,
    CASE t.priority
        WHEN 1 THEN 'High'
        WHEN 2 THEN 'Medium'
        WHEN 3 THEN 'Low'
    END as priority,
    t.status,
    t.due_date,
    u1.first_name || ' ' || u1.last_name as created_by,
    u2.first_name || ' ' || u2.last_name as assigned_to
FROM tasks t
JOIN users u1 ON t.created_by = u1.id
JOIN users u2 ON t.developer_id = u2.id
WHERE t.created_by = (
    SELECT created_by
    FROM deals
    WHERE title = 'Тестовый проект автоматизации'
)
AND t.created_at >= (
    SELECT created_at
    FROM deals
    WHERE title = 'Тестовый проект автоматизации'
)
ORDER BY t.due_date;

-- Проверяем количество задач после
SELECT COUNT(*) as tasks_after FROM tasks;

-- Проверяем статистику созданных задач
SELECT
    CASE priority
        WHEN 1 THEN 'High'
        WHEN 2 THEN 'Medium'
        WHEN 3 THEN 'Low'
    END as priority,
    status,
    COUNT(*) as tasks_count,
    MIN(due_date) as earliest_due_date,
    MAX(due_date) as latest_due_date
FROM tasks
WHERE created_by = (
    SELECT created_by
    FROM deals
    WHERE title = 'Тестовый проект автоматизации'
)
AND created_at >= (
    SELECT created_at
    FROM deals
    WHERE title = 'Тестовый проект автоматизации'
)
GROUP BY priority, status
ORDER BY priority, status;
