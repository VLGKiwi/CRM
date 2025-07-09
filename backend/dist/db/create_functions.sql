-- Функция 1: Расчет эффективности пользователя
CREATE OR REPLACE FUNCTION calculate_user_efficiency(
    p_user_id UUID,
    p_start_date DATE DEFAULT (CURRENT_DATE - INTERVAL '1 year')::DATE,
    p_end_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    total_deals INTEGER,
    won_deals INTEGER,
    lost_deals INTEGER,
    success_rate DECIMAL,
    total_revenue DECIMAL,
    avg_deal_size DECIMAL,
    avg_deal_duration INTEGER,
    total_tasks INTEGER,
    completed_tasks INTEGER,
    task_completion_rate DECIMAL,
    avg_task_hours DECIMAL
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH deal_metrics AS (
        SELECT
            COUNT(*) as total_deals,
            COUNT(*) FILTER (WHERE stage = 'Closed Won') as won_deals,
            COUNT(*) FILTER (WHERE stage = 'Closed Lost') as lost_deals,
            SUM(amount) FILTER (WHERE stage = 'Closed Won') as total_revenue,
            AVG(amount) FILTER (WHERE stage = 'Closed Won') as avg_deal_size,
            AVG(EXTRACT(EPOCH FROM (actual_close_date - created_at))/86400)::INTEGER
                FILTER (WHERE actual_close_date IS NOT NULL) as avg_deal_duration
        FROM deals
        WHERE created_by = p_user_id
        AND created_at BETWEEN p_start_date AND p_end_date
    ),
    task_metrics AS (
        SELECT
            COUNT(*) as total_tasks,
            COUNT(*) FILTER (WHERE status = 'Completed') as completed_tasks,
            AVG(actual_hours) as avg_task_hours
        FROM tasks
        WHERE created_by = p_user_id
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
        END as success_rate,
        COALESCE(dm.total_revenue, 0),
        COALESCE(dm.avg_deal_size, 0),
        COALESCE(dm.avg_deal_duration, 0),
        tm.total_tasks,
        tm.completed_tasks,
        CASE
            WHEN tm.total_tasks > 0 THEN
                ROUND((tm.completed_tasks::DECIMAL / tm.total_tasks * 100), 2)
            ELSE 0
        END as task_completion_rate,
        COALESCE(tm.avg_task_hours, 0)
    FROM deal_metrics dm
    CROSS JOIN task_metrics tm;
END;
$$;

-- Функция 2: Анализ воронки продаж
CREATE OR REPLACE FUNCTION analyze_sales_funnel(
    p_start_date DATE DEFAULT (CURRENT_DATE - INTERVAL '1 year')::DATE,
    p_end_date DATE DEFAULT CURRENT_DATE,
    p_industry VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    stage VARCHAR,
    deals_count INTEGER,
    total_amount DECIMAL,
    avg_amount DECIMAL,
    conversion_rate DECIMAL,
    avg_duration INTEGER,
    top_users JSON
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH stage_metrics AS (
        SELECT
            d.stage,
            COUNT(*) as deals_count,
            SUM(d.amount) as total_amount,
            AVG(d.amount) as avg_amount,
            AVG(EXTRACT(EPOCH FROM (d.actual_close_date - d.created_at))/86400)::INTEGER
                as avg_duration,
            json_agg(json_build_object(
                'user_id', u.id,
                'name', u.first_name || ' ' || u.last_name,
                'deals_count', COUNT(*),
                'total_amount', SUM(d.amount)
            )) FILTER (WHERE u.id IS NOT NULL) as users_data
        FROM deals d
        LEFT JOIN users u ON d.created_by = u.id
        LEFT JOIN clients c ON d.client_id = c.id
        WHERE d.created_at BETWEEN p_start_date AND p_end_date
        AND (p_industry IS NULL OR c.industry = p_industry)
        GROUP BY d.stage
    ),
    stage_totals AS (
        SELECT SUM(deals_count) as total_deals
        FROM stage_metrics
    )
    SELECT
        sm.stage,
        sm.deals_count,
        sm.total_amount,
        sm.avg_amount,
        ROUND((sm.deals_count::DECIMAL / st.total_deals * 100), 2) as conversion_rate,
        sm.avg_duration,
        (
            SELECT json_agg(user_data)
            FROM (
                SELECT *
                FROM json_array_elements(sm.users_data) as user_data
                ORDER BY (user_data->>'total_amount')::DECIMAL DESC
                LIMIT 5
            ) top_5
        ) as top_users
    FROM stage_metrics sm
    CROSS JOIN stage_totals st
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

-- Функция 3: Расчет прогноза продаж
CREATE OR REPLACE FUNCTION calculate_sales_forecast(
    p_months_ahead INTEGER DEFAULT 3,
    p_user_id UUID DEFAULT NULL
)
RETURNS TABLE (
    forecast_month DATE,
    predicted_deals INTEGER,
    predicted_amount DECIMAL,
    confidence_score DECIMAL
) LANGUAGE plpgsql AS $$
DECLARE
    v_avg_monthly_deals DECIMAL;
    v_avg_deal_amount DECIMAL;
    v_success_rate DECIMAL;
    v_seasonality_factor DECIMAL;
BEGIN
    -- Рассчитываем базовые метрики
    WITH monthly_stats AS (
        SELECT
            DATE_TRUNC('month', created_at) as deal_month,
            COUNT(*) as deals_count,
            AVG(amount) as avg_amount,
            COUNT(*) FILTER (WHERE stage = 'Closed Won') / COUNT(*)::DECIMAL as success_rate
        FROM deals
        WHERE created_at >= CURRENT_DATE - INTERVAL '2 years'
        AND (p_user_id IS NULL OR created_by = p_user_id)
        GROUP BY DATE_TRUNC('month', created_at)
    )
    SELECT
        AVG(deals_count),
        AVG(avg_amount),
        AVG(success_rate)
    INTO v_avg_monthly_deals, v_avg_deal_amount, v_success_rate
    FROM monthly_stats;

    -- Возвращаем прогноз для каждого месяца
    RETURN QUERY
    SELECT
        (CURRENT_DATE + (generate_series || ' months')::INTERVAL)::DATE as forecast_month,
        CEIL(v_avg_monthly_deals *
            CASE EXTRACT(MONTH FROM (CURRENT_DATE + (generate_series || ' months')::INTERVAL))
                WHEN 12 THEN 1.2  -- Декабрь
                WHEN 1 THEN 0.8   -- Январь
                WHEN 7 THEN 0.9   -- Июль
                WHEN 8 THEN 0.9   -- Август
                ELSE 1.0
            END)::INTEGER as predicted_deals,
        ROUND(v_avg_deal_amount *
            CEIL(v_avg_monthly_deals *
                CASE EXTRACT(MONTH FROM (CURRENT_DATE + (generate_series || ' months')::INTERVAL))
                    WHEN 12 THEN 1.2
                    WHEN 1 THEN 0.8
                    WHEN 7 THEN 0.9
                    WHEN 8 THEN 0.9
                    ELSE 1.0
                END) * v_success_rate, 2) as predicted_amount,
        ROUND(v_success_rate * 100 *
            CASE
                WHEN generate_series = 1 THEN 0.9
                WHEN generate_series = 2 THEN 0.8
                WHEN generate_series = 3 THEN 0.7
                ELSE 0.6
            END, 2) as confidence_score
    FROM generate_series(1, p_months_ahead);
END;
$$;

-- Функция 4: Анализ активности клиента
CREATE OR REPLACE FUNCTION analyze_client_activity(
    p_client_id UUID,
    p_months_back INTEGER DEFAULT 12
)
RETURNS TABLE (
    activity_month DATE,
    deals_count INTEGER,
    deals_amount DECIMAL,
    tasks_count INTEGER,
    completed_tasks INTEGER,
    activities_count INTEGER,
    interaction_score INTEGER
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH RECURSIVE months AS (
        SELECT DATE_TRUNC('month', CURRENT_DATE - (p_months_back || ' months')::INTERVAL)::DATE as month
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
        AND created_at >= CURRENT_DATE - (p_months_back || ' months')::INTERVAL
        GROUP BY DATE_TRUNC('month', created_at)::DATE
    ),
    task_metrics AS (
        SELECT
            DATE_TRUNC('month', created_at)::DATE as activity_month,
            COUNT(*) as tasks_count,
            COUNT(*) FILTER (WHERE status = 'Completed') as completed_tasks
        FROM tasks
        WHERE client_id = p_client_id
        AND created_at >= CURRENT_DATE - (p_months_back || ' months')::INTERVAL
        GROUP BY DATE_TRUNC('month', created_at)::DATE
    ),
    activity_metrics AS (
        SELECT
            DATE_TRUNC('month', created_at)::DATE as activity_month,
            COUNT(*) as activities_count
        FROM activities
        WHERE client_id = p_client_id
        AND created_at >= CURRENT_DATE - (p_months_back || ' months')::INTERVAL
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
        ) as interaction_score
    FROM months m
    LEFT JOIN deal_metrics d ON m.month = d.activity_month
    LEFT JOIN task_metrics t ON m.month = t.activity_month
    LEFT JOIN activity_metrics a ON m.month = a.activity_month
    ORDER BY m.month DESC;
END;
$$;
