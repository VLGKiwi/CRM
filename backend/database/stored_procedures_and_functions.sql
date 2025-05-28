-- ============================================================================
-- ХРАНИМЫЕ ПРОЦЕДУРЫ
-- ============================================================================

-- Процедура 1: Создание нового клиента с контактами и первичной активностью
CREATE OR REPLACE PROCEDURE create_client_with_contacts(
    p_company_name VARCHAR,
    p_industry VARCHAR,
    p_website VARCHAR,
    p_phone VARCHAR,
    p_address TEXT,
    p_city VARCHAR,
    p_country VARCHAR,
    p_postal_code VARCHAR,
    p_assigned_to UUID,
    p_contacts JSONB
) LANGUAGE plpgsql AS $$
DECLARE
    v_client_id INTEGER;
    v_contact JSONB;
    v_priority VARCHAR;
BEGIN
    -- Определяем приоритет на основе индустрии
    v_priority := CASE
        WHEN p_industry IN ('Technology', 'Healthcare', 'Finance') THEN 'High'
        WHEN p_industry IN ('Retail', 'Manufacturing') THEN 'Medium'
        ELSE 'Low'
    END;

    -- Создаем клиента
    INSERT INTO clients (
        company_name, industry, website, phone, address,
        city, country, postal_code, assigned_to, status
    ) VALUES (
        p_company_name, p_industry, p_website, p_phone, p_address,
        p_city, p_country, p_postal_code, p_assigned_to, 'Active'
    ) RETURNING id INTO v_client_id;

    -- Создаем контакты
    FOR v_contact IN SELECT * FROM jsonb_array_elements(p_contacts)
    LOOP
        INSERT INTO contacts (
            client_id, first_name, last_name, email, phone,
            position, is_primary
        ) VALUES (
            v_client_id,
            v_contact->>'first_name',
            v_contact->>'last_name',
            v_contact->>'email',
            v_contact->>'phone',
            v_contact->>'position',
            (v_contact->>'is_primary')::boolean
        );
    END LOOP;

    -- Создаем первичную активность
    INSERT INTO activities (
        type, subject, description, client_id, created_by
    ) VALUES (
        'Initial Contact',
        'New Client Registration',
        'Client ' || p_company_name || ' has been registered in the system',
        v_client_id,
        p_assigned_to
    );
END;
$$;

-- Процедура 2: Создание сделки с автоматическими задачами
CREATE OR REPLACE PROCEDURE create_deal_with_tasks(
    p_client_id INTEGER,
    p_title VARCHAR,
    p_amount DECIMAL,
    p_currency VARCHAR,
    p_stage VARCHAR,
    p_created_by UUID,
    p_assigned_to UUID
) LANGUAGE plpgsql AS $$
DECLARE
    v_deal_id INTEGER;
    v_client_industry VARCHAR;
    v_task_count INTEGER := 0;
BEGIN
    -- Получаем индустрию клиента
    SELECT industry INTO v_client_industry
    FROM clients
    WHERE id = p_client_id;

    -- Создаем сделку
    INSERT INTO deals (
        client_id, title, amount, currency, stage,
        created_by, assigned_to
    ) VALUES (
        p_client_id, p_title, p_amount, p_currency, p_stage,
        p_created_by, p_assigned_to
    ) RETURNING id INTO v_deal_id;

    -- Создаем задачи в зависимости от стадии и суммы
    LOOP
        v_task_count := v_task_count + 1;

        -- Создаем разные задачи в зависимости от стадии
        CASE p_stage
            WHEN 'Initial Contact' THEN
                INSERT INTO tasks (title, description, priority, status, deal_id, created_by)
                VALUES (
                    'Квалификация клиента',
                    'Провести первичную квалификацию потребностей',
                    CASE WHEN p_amount > 100000 THEN 'High' ELSE 'Medium' END,
                    'New',
                    v_deal_id,
                    p_created_by
                );
            WHEN 'Negotiation' THEN
                INSERT INTO tasks (title, description, priority, status, deal_id, created_by)
                VALUES (
                    'Подготовка коммерческого предложения',
                    'Сформировать КП на основе обсуждения',
                    'High',
                    'New',
                    v_deal_id,
                    p_created_by
                );
        END CASE;

        EXIT WHEN v_task_count >= 2;
    END LOOP;

    -- Создаем активность для сделки
    INSERT INTO activities (
        type, subject, description, deal_id, created_by
    ) VALUES (
        'Deal Creation',
        'New Deal: ' || p_title,
        'Created new deal for amount ' || p_amount || ' ' || p_currency,
        v_deal_id,
        p_created_by
    );
END;
$$;

-- Процедура 3: Массовое обновление задач
CREATE OR REPLACE PROCEDURE bulk_update_tasks(
    p_status VARCHAR,
    p_new_status VARCHAR,
    p_assigned_to UUID,
    p_due_date_start DATE,
    p_due_date_end DATE
) LANGUAGE plpgsql AS $$
DECLARE
    v_updated_count INTEGER;
    v_task RECORD;
    v_activity_description TEXT;
BEGIN
    -- Подсчитываем количество задач для обновления
    SELECT COUNT(*) INTO v_updated_count
    FROM tasks
    WHERE status = p_status
    AND (p_assigned_to IS NULL OR developer_id = p_assigned_to)
    AND (
        p_due_date_start IS NULL
        OR (due_date BETWEEN p_due_date_start AND p_due_date_end)
    );

    -- Проверяем есть ли задачи для обновления
    IF v_updated_count = 0 THEN
        RAISE NOTICE 'No tasks found for update with given criteria';
        RETURN;
    END IF;

    -- Обновляем задачи и создаем активности
    FOR v_task IN
        SELECT id, title
        FROM tasks
        WHERE status = p_status
        AND (p_assigned_to IS NULL OR developer_id = p_assigned_to)
        AND (
            p_due_date_start IS NULL
            OR (due_date BETWEEN p_due_date_start AND p_due_date_end)
        )
    LOOP
        -- Обновляем статус задачи
        UPDATE tasks
        SET
            status = p_new_status,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = v_task.id;

        -- Формируем описание для активности
        v_activity_description := 'Task status changed from ' || p_status || ' to ' || p_new_status;

        -- Создаем запись активности
        INSERT INTO activities (
            type,
            subject,
            description,
            created_by
        ) VALUES (
            'Task Update',
            'Status update for task: ' || v_task.title,
            v_activity_description,
            p_assigned_to
        );
    END LOOP;

    RAISE NOTICE 'Successfully updated % tasks', v_updated_count;
END;
$$;

-- ============================================================================
-- ФУНКЦИИ
-- ============================================================================

-- Функция 1: Расчет эффективности сотрудника
CREATE OR REPLACE FUNCTION calculate_employee_efficiency(
    p_employee_id UUID,
    p_start_date DATE DEFAULT CURRENT_DATE - INTERVAL '6 months',
    p_end_date DATE DEFAULT CURRENT_DATE
) RETURNS TABLE (
    total_deals INTEGER,
    won_deals INTEGER,
    lost_deals INTEGER,
    success_rate DECIMAL,
    total_revenue DECIMAL,
    avg_deal_size DECIMAL,
    total_tasks INTEGER,
    completed_tasks INTEGER,
    task_completion_rate DECIMAL
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH deal_metrics AS (
        SELECT
            COUNT(*) as total_deals,
            COUNT(*) FILTER (WHERE stage = 'Closed Won') as won_deals,
            COUNT(*) FILTER (WHERE stage = 'Closed Lost') as lost_deals,
            SUM(amount) FILTER (WHERE stage = 'Closed Won') as total_revenue,
            AVG(amount) FILTER (WHERE stage = 'Closed Won') as avg_deal_size
        FROM deals
        WHERE created_by = p_employee_id
        AND created_at BETWEEN p_start_date AND p_end_date
    ),
    task_metrics AS (
        SELECT
            COUNT(*) as total_tasks,
            COUNT(*) FILTER (WHERE status = 'Completed') as completed_tasks
        FROM tasks
        WHERE developer_id = p_employee_id
        AND created_at BETWEEN p_start_date AND p_end_date
    )
    SELECT
        dm.total_deals,
        dm.won_deals,
        dm.lost_deals,
        CASE
            WHEN dm.total_deals > 0 THEN
                ROUND((dm.won_deals::DECIMAL / dm.total_deals * 100), 2)
            ELSE 0
        END,
        COALESCE(dm.total_revenue, 0),
        COALESCE(dm.avg_deal_size, 0),
        tm.total_tasks,
        tm.completed_tasks,
        CASE
            WHEN tm.total_tasks > 0 THEN
                ROUND((tm.completed_tasks::DECIMAL / tm.total_tasks * 100), 2)
            ELSE 0
        END
    FROM deal_metrics dm
    CROSS JOIN task_metrics tm;
END;
$$;

-- Функция 2: Анализ воронки продаж по индустрии
CREATE OR REPLACE FUNCTION analyze_sales_funnel(
    p_industry VARCHAR,
    p_start_date DATE DEFAULT CURRENT_DATE - INTERVAL '1 year',
    p_end_date DATE DEFAULT CURRENT_DATE
) RETURNS TABLE (
    stage VARCHAR,
    deals_count INTEGER,
    total_amount DECIMAL,
    conversion_rate DECIMAL,
    avg_deal_size DECIMAL,
    avg_days_in_stage INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    v_total_deals INTEGER;
BEGIN
    -- Получаем общее количество сделок
    SELECT COUNT(*) INTO v_total_deals
    FROM deals d
    JOIN clients c ON d.client_id = c.id
    WHERE c.industry = p_industry
    AND d.created_at BETWEEN p_start_date AND p_end_date;

    RETURN QUERY
    WITH stage_metrics AS (
        SELECT
            d.stage,
            COUNT(*) as deals_count,
            SUM(d.amount) as total_amount,
            AVG(d.amount) as avg_deal_size,
            AVG(
                EXTRACT(EPOCH FROM (
                    COALESCE(d.actual_close_date, CURRENT_DATE) - d.created_at
                ))/86400
            )::INTEGER as days_in_stage
        FROM deals d
        JOIN clients c ON d.client_id = c.id
        WHERE c.industry = p_industry
        AND d.created_at BETWEEN p_start_date AND p_end_date
        GROUP BY d.stage
    )
    SELECT
        sm.stage,
        sm.deals_count,
        sm.total_amount,
        ROUND((sm.deals_count::DECIMAL / v_total_deals * 100), 2) as conversion_rate,
        ROUND(sm.avg_deal_size, 2) as avg_deal_size,
        sm.days_in_stage
    FROM stage_metrics sm
    ORDER BY
        CASE sm.stage
            WHEN 'Initial Contact' THEN 1
            WHEN 'Qualification' THEN 2
            WHEN 'Proposal' THEN 3
            WHEN 'Negotiation' THEN 4
            WHEN 'Closed Won' THEN 5
            WHEN 'Closed Lost' THEN 6
        END;
END;
$$;

-- Функция 3: Анализ активности клиента
CREATE OR REPLACE FUNCTION analyze_client_activity(
    p_client_id INTEGER,
    p_months_back INTEGER DEFAULT 6
) RETURNS TABLE (
    activity_month DATE,
    deals_count INTEGER,
    deals_amount DECIMAL,
    tasks_count INTEGER,
    completed_tasks INTEGER,
    activities_count INTEGER,
    engagement_score INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    v_start_date DATE := CURRENT_DATE - (p_months_back || ' months')::INTERVAL;
BEGIN
    RETURN QUERY
    WITH RECURSIVE months AS (
        SELECT DATE_TRUNC('month', v_start_date)::DATE as month
        UNION ALL
        SELECT (month + INTERVAL '1 month')::DATE
        FROM months
        WHERE month < DATE_TRUNC('month', CURRENT_DATE)::DATE
    ),
    deal_metrics AS (
        SELECT
            DATE_TRUNC('month', created_at)::DATE as activity_month,
            COUNT(*) as deals_count,
            SUM(amount) as deals_amount
        FROM deals
        WHERE client_id = p_client_id
        AND created_at >= v_start_date
        GROUP BY DATE_TRUNC('month', created_at)::DATE
    ),
    task_metrics AS (
        SELECT
            DATE_TRUNC('month', created_at)::DATE as activity_month,
            COUNT(*) as tasks_count,
            COUNT(*) FILTER (WHERE status = 'Completed') as completed_tasks
        FROM tasks
        WHERE client_id = p_client_id
        AND created_at >= v_start_date
        GROUP BY DATE_TRUNC('month', created_at)::DATE
    ),
    activity_metrics AS (
        SELECT
            DATE_TRUNC('month', created_at)::DATE as activity_month,
            COUNT(*) as activities_count
        FROM activities
        WHERE client_id = p_client_id
        AND created_at >= v_start_date
        GROUP BY DATE_TRUNC('month', created_at)::DATE
    )
    SELECT
        m.month as activity_month,
        COALESCE(d.deals_count, 0) as deals_count,
        COALESCE(d.deals_amount, 0) as deals_amount,
        COALESCE(t.tasks_count, 0) as tasks_count,
        COALESCE(t.completed_tasks, 0) as completed_tasks,
        COALESCE(a.activities_count, 0) as activities_count,
        (
            COALESCE(d.deals_count, 0) * 10 +
            COALESCE(t.completed_tasks, 0) * 5 +
            COALESCE(a.activities_count, 0) * 2
        ) as engagement_score
    FROM months m
    LEFT JOIN deal_metrics d ON m.month = d.activity_month
    LEFT JOIN task_metrics t ON m.month = t.activity_month
    LEFT JOIN activity_metrics a ON m.month = a.activity_month
    ORDER BY m.month DESC;
END;
$$;

-- ============================================================================
-- ПРИМЕРЫ ВЫЗОВА
-- ============================================================================

-- Тест Процедуры 1: Создание клиента с контактами
CALL create_client_with_contacts(
    'Tech Solutions Inc',
    'Technology',
    'www.techsolutions.com',
    '+1-555-0123',
    '123 Tech Street',
    'San Francisco',
    'USA',
    '94105',
    'e89b2fdd-4f16-4f32-8e6a-0c29c1a8e6e5'::UUID,
    '[
        {
            "first_name": "John",
            "last_name": "Doe",
            "email": "john@techsolutions.com",
            "phone": "+1-555-0124",
            "position": "CEO",
            "is_primary": true
        },
        {
            "first_name": "Jane",
            "last_name": "Smith",
            "email": "jane@techsolutions.com",
            "phone": "+1-555-0125",
            "position": "CTO",
            "is_primary": false
        }
    ]'::JSONB
);

-- Тест Процедуры 2: Создание сделки с задачами
CALL create_deal_with_tasks(
    1,                                              -- client_id
    'Enterprise Software License',                   -- title
    50000,                                          -- amount
    'USD',                                          -- currency
    'Initial Contact',                              -- stage
    'e89b2fdd-4f16-4f32-8e6a-0c29c1a8e6e5'::UUID,  -- created_by
    'e89b2fdd-4f16-4f32-8e6a-0c29c1a8e6e5'::UUID   -- assigned_to
);

-- Тест Процедуры 3: Массовое обновление задач
CALL bulk_update_tasks(
    'In Progress',                                  -- current status
    'Completed',                                    -- new status
    'e89b2fdd-4f16-4f32-8e6a-0c29c1a8e6e5'::UUID,  -- assigned_to
    '2024-01-01',                                   -- due_date_start
    '2024-03-31'                                    -- due_date_end
);

-- Тест Функции 1: Расчет эффективности сотрудника
SELECT * FROM calculate_employee_efficiency(
    'e89b2fdd-4f16-4f32-8e6a-0c29c1a8e6e5'::UUID,  -- employee_id
    '2024-01-01',                                   -- start_date
    '2024-03-31'                                    -- end_date
);

-- Тест Функции 2: Анализ воронки продаж
SELECT * FROM analyze_sales_funnel(
    'Technology',                                   -- industry
    '2024-01-01',                                  -- start_date
    '2024-03-31'                                   -- end_date
);

-- Тест Функции 3: Анализ активности клиента
SELECT * FROM analyze_client_activity(
    1,                                             -- client_id
    6                                              -- months_back
);
