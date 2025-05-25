-- Процедура 1: Создание новой сделки с автоматическими задачами
CREATE OR REPLACE PROCEDURE create_deal_with_tasks(
    p_client_id UUID,
    p_employee_id UUID,
    p_deal_name VARCHAR,
    p_amount DECIMAL,
    p_status VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_deal_id UUID;
    v_client_industry VARCHAR;
BEGIN
    -- Получаем индустрию клиента
    SELECT industry INTO v_client_industry FROM clients WHERE client_id = p_client_id;

    -- Создаем сделку
    INSERT INTO deals (deal_id, client_id, employee_id, deal_name, amount, status, created_at)
    VALUES (gen_random_uuid(), p_client_id, p_employee_id, p_deal_name, p_amount, p_status, NOW())
    RETURNING deal_id INTO v_deal_id;

    -- Создаем задачи в зависимости от статуса и индустрии
    IF p_status = 'New' THEN
        -- Создаем задачу квалификации
        INSERT INTO tasks (task_id, employee_id, deal_id, title, description, due_date, status, priority)
        VALUES (
            gen_random_uuid(),
            p_employee_id,
            v_deal_id,
            'Квалификация клиента',
            'Провести первичную квалификацию клиента и определить потребности',
            NOW() + INTERVAL '2 days',
            'Not Started',
            CASE
                WHEN p_amount > 1000000 THEN 'High'
                ELSE 'Medium'
            END
        );
    END IF;

    IF v_client_industry = 'IT' THEN
        -- Дополнительная техническая задача для IT-клиентов
        INSERT INTO tasks (task_id, employee_id, deal_id, title, description, due_date, status, priority)
        VALUES (
            gen_random_uuid(),
            p_employee_id,
            v_deal_id,
            'Техническая консультация',
            'Организовать встречу с техническими специалистами',
            NOW() + INTERVAL '5 days',
            'Not Started',
            'High'
        );
    END IF;
END;
$$;

-- Процедура 2: Обновление статусов просроченных задач и уведомление
CREATE OR REPLACE PROCEDURE update_overdue_tasks()
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Подсчитываем количество просроченных задач
    SELECT COUNT(*) INTO v_count
    FROM tasks
    WHERE due_date < NOW()
    AND status NOT IN ('Completed', 'Delayed');

    -- Обновляем статус просроченных задач
    UPDATE tasks
    SET
        status = 'Delayed',
        description = description || E'\nПомечено как просроченное ' || NOW()::DATE::TEXT
    WHERE due_date < NOW()
    AND status NOT IN ('Completed', 'Delayed');

    -- Создаем запись в логе если были обновления
    IF v_count > 0 THEN
        INSERT INTO task_logs (log_id, event_type, description, created_at)
        VALUES (
            gen_random_uuid(),
            'OVERDUE_UPDATE',
            'Updated ' || v_count || ' overdue tasks',
            NOW()
        );
    END IF;
END;
$$;

-- Процедура 3: Расчет бонусов для сотрудников
CREATE OR REPLACE PROCEDURE calculate_employee_bonuses(
    p_start_date DATE,
    p_end_date DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_employee_record RECORD;
    v_bonus_amount DECIMAL;
    v_deals_count INTEGER;
    v_total_amount DECIMAL;
BEGIN
    FOR v_employee_record IN
        SELECT employee_id, first_name, last_name
        FROM employees
    LOOP
        -- Подсчитываем количество успешных сделок
        SELECT
            COUNT(*),
            COALESCE(SUM(amount), 0)
        INTO
            v_deals_count,
            v_total_amount
        FROM deals
        WHERE employee_id = v_employee_record.employee_id
        AND status = 'Closed Won'
        AND created_at BETWEEN p_start_date AND p_end_date;

        -- Рассчитываем бонус
        IF v_deals_count > 0 THEN
            v_bonus_amount := CASE
                WHEN v_total_amount > 1000000 THEN v_total_amount * 0.05
                WHEN v_total_amount > 500000 THEN v_total_amount * 0.03
                ELSE v_total_amount * 0.01
            END;

            -- Записываем информацию о бонусе
            INSERT INTO employee_bonuses (
                bonus_id,
                employee_id,
                period_start,
                period_end,
                deals_count,
                total_amount,
                bonus_amount
            ) VALUES (
                gen_random_uuid(),
                v_employee_record.employee_id,
                p_start_date,
                p_end_date,
                v_deals_count,
                v_total_amount,
                v_bonus_amount
            );
        END IF;
    END LOOP;
END;
$$;

-- Функция 1: Расчет эффективности сотрудника
CREATE OR REPLACE FUNCTION calculate_employee_efficiency(
    p_employee_id UUID,
    p_start_date DATE DEFAULT NULL,
    p_end_date DATE DEFAULT NULL
)
RETURNS TABLE (
    total_deals INTEGER,
    won_deals INTEGER,
    success_rate DECIMAL,
    total_amount DECIMAL,
    avg_deal_amount DECIMAL,
    completed_tasks INTEGER,
    task_completion_rate DECIMAL
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH deal_stats AS (
        SELECT
            COUNT(*) as total_deals,
            COUNT(*) FILTER (WHERE status = 'Closed Won') as won_deals,
            SUM(amount) FILTER (WHERE status = 'Closed Won') as total_amount,
            AVG(amount) FILTER (WHERE status = 'Closed Won') as avg_deal_amount
        FROM deals
        WHERE employee_id = p_employee_id
        AND (p_start_date IS NULL OR created_at >= p_start_date)
        AND (p_end_date IS NULL OR created_at <= p_end_date)
    ),
    task_stats AS (
        SELECT
            COUNT(*) as total_tasks,
            COUNT(*) FILTER (WHERE status = 'Completed') as completed_tasks
        FROM tasks
        WHERE employee_id = p_employee_id
        AND (p_start_date IS NULL OR due_date >= p_start_date)
        AND (p_end_date IS NULL OR due_date <= p_end_date)
    )
    SELECT
        d.total_deals,
        d.won_deals,
        CASE
            WHEN d.total_deals > 0 THEN (d.won_deals::DECIMAL / d.total_deals * 100)
            ELSE 0
        END as success_rate,
        COALESCE(d.total_amount, 0),
        COALESCE(d.avg_deal_amount, 0),
        t.completed_tasks,
        CASE
            WHEN t.total_tasks > 0 THEN (t.completed_tasks::DECIMAL / t.total_tasks * 100)
            ELSE 0
        END as task_completion_rate
    FROM deal_stats d
    CROSS JOIN task_stats t;
END;
$$;

-- Функция 2: Поиск потенциальных клиентов
CREATE OR REPLACE FUNCTION find_potential_clients(
    p_industry VARCHAR DEFAULT NULL,
    p_min_revenue DECIMAL DEFAULT 0,
    p_min_deals INTEGER DEFAULT 0
)
RETURNS TABLE (
    client_id UUID,
    company_name VARCHAR,
    industry VARCHAR,
    annual_revenue DECIMAL,
    total_deals INTEGER,
    total_amount DECIMAL,
    last_deal_date TIMESTAMP,
    contact_count INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.client_id,
        c.company_name,
        c.industry,
        c.annual_revenue,
        COUNT(DISTINCT d.deal_id) as total_deals,
        COALESCE(SUM(d.amount), 0) as total_amount,
        MAX(d.created_at) as last_deal_date,
        COUNT(DISTINCT co.contact_id) as contact_count
    FROM clients c
    LEFT JOIN deals d ON c.client_id = d.client_id
    LEFT JOIN contacts co ON c.client_id = co.client_id
    WHERE (p_industry IS NULL OR c.industry = p_industry)
    AND c.annual_revenue >= p_min_revenue
    GROUP BY c.client_id, c.company_name, c.industry, c.annual_revenue
    HAVING COUNT(DISTINCT d.deal_id) >= p_min_deals
    ORDER BY c.annual_revenue DESC, total_deals DESC;
END;
$$;

-- Функция 3: Анализ воронки продаж
CREATE OR REPLACE FUNCTION analyze_sales_funnel(
    p_start_date DATE,
    p_end_date DATE,
    p_industry VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    stage VARCHAR,
    deals_count INTEGER,
    total_amount DECIMAL,
    conversion_rate DECIMAL,
    avg_time_in_stage INTERVAL
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH stage_stats AS (
        SELECT
            d.status as stage,
            COUNT(*) as deals_count,
            SUM(d.amount) as total_amount,
            AVG(
                CASE
                    WHEN d.closed_at IS NOT NULL THEN
                        d.closed_at - d.created_at
                    ELSE
                        NOW() - d.created_at
                END
            ) as avg_time_in_stage
        FROM deals d
        JOIN clients c ON d.client_id = c.client_id
        WHERE d.created_at BETWEEN p_start_date AND p_end_date
        AND (p_industry IS NULL OR c.industry = p_industry)
        GROUP BY d.status
    ),
    total_deals AS (
        SELECT SUM(deals_count) as total
        FROM stage_stats
    )
    SELECT
        s.stage,
        s.deals_count,
        s.total_amount,
        CASE
            WHEN t.total > 0 THEN (s.deals_count::DECIMAL / t.total * 100)
            ELSE 0
        END as conversion_rate,
        s.avg_time_in_stage
    FROM stage_stats s
    CROSS JOIN total_deals t
    ORDER BY
        CASE s.stage
            WHEN 'New' THEN 1
            WHEN 'Qualified' THEN 2
            WHEN 'Proposal' THEN 3
            WHEN 'Negotiation' THEN 4
            WHEN 'Closed Won' THEN 5
            WHEN 'Closed Lost' THEN 6
        END;
END;
$$;
