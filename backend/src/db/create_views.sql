-- Представление 1: Детальная информация о клиентах
CREATE OR REPLACE VIEW vw_client_details AS
SELECT
    c.id,
    c.company_name,
    c.industry,
    c.website,
    c.phone,
    c.address,
    c.city,
    c.country,
    c.status,
    u.first_name || ' ' || u.last_name as assigned_to_name,
    COUNT(DISTINCT d.id) as total_deals,
    COUNT(DISTINCT d.id) FILTER (WHERE d.stage = 'Closed Won') as won_deals,
    COUNT(DISTINCT d.id) FILTER (WHERE d.stage = 'Closed Lost') as lost_deals,
    COALESCE(SUM(d.amount) FILTER (WHERE d.stage = 'Closed Won'), 0) as total_revenue,
    COUNT(DISTINCT co.id) as contacts_count,
    STRING_AGG(DISTINCT co.position, ', ') as contact_positions,
    MAX(d.created_at) as last_deal_date
FROM clients c
LEFT JOIN deals d ON c.id = d.client_id
LEFT JOIN contacts co ON c.id = co.client_id
LEFT JOIN users u ON c.assigned_to = u.id
GROUP BY c.id, c.company_name, c.industry, c.website, c.phone, c.address, c.city, c.country, c.status, u.first_name, u.last_name;

-- Представление 2: Эффективность пользователей
CREATE OR REPLACE VIEW vw_user_performance AS
WITH deal_stats AS (
    SELECT
        u.id as user_id,
        COUNT(d.id) as total_deals,
        COUNT(*) FILTER (WHERE d.stage = 'Closed Won') as won_deals,
        COUNT(*) FILTER (WHERE d.stage = 'Closed Lost') as lost_deals,
        SUM(d.amount) FILTER (WHERE d.stage = 'Closed Won') as total_revenue,
        AVG(d.amount) FILTER (WHERE d.stage = 'Closed Won') as avg_deal_size
    FROM users u
    LEFT JOIN deals d ON u.id = d.created_by
    WHERE d.created_at >= NOW() - INTERVAL '1 year'
    GROUP BY u.id
),
task_stats AS (
    SELECT
        created_by as user_id,
        COUNT(*) as total_tasks,
        COUNT(*) FILTER (WHERE status = 'Completed') as completed_tasks,
        COUNT(*) FILTER (WHERE status = 'Delayed') as delayed_tasks,
        AVG(actual_hours) as avg_task_hours
    FROM tasks
    WHERE due_date >= NOW() - INTERVAL '1 year'
    GROUP BY created_by
)
SELECT
    u.id as user_id,
    u.first_name || ' ' || u.last_name as user_name,
    r.name as role_name,
    t.name as team_name,
    u.email,
    COALESCE(ds.total_deals, 0) as total_deals,
    COALESCE(ds.won_deals, 0) as won_deals,
    COALESCE(ds.lost_deals, 0) as lost_deals,
    CASE
        WHEN COALESCE(ds.total_deals, 0) > 0
        THEN ROUND((ds.won_deals::DECIMAL / ds.total_deals * 100), 2)
        ELSE 0
    END as success_rate,
    COALESCE(ds.total_revenue, 0) as total_revenue,
    COALESCE(ds.avg_deal_size, 0) as avg_deal_size,
    COALESCE(ts.total_tasks, 0) as total_tasks,
    COALESCE(ts.completed_tasks, 0) as completed_tasks,
    COALESCE(ts.delayed_tasks, 0) as delayed_tasks,
    COALESCE(ts.avg_task_hours, 0) as avg_task_hours,
    CASE
        WHEN COALESCE(ts.total_tasks, 0) > 0
        THEN ROUND((ts.completed_tasks::DECIMAL / ts.total_tasks * 100), 2)
        ELSE 0
    END as task_completion_rate
FROM users u
LEFT JOIN deal_stats ds ON u.id = ds.user_id
LEFT JOIN task_stats ts ON u.id = ts.user_id
LEFT JOIN roles r ON u.role_id = r.id
LEFT JOIN teams t ON u.team_id = t.id
WHERE u.is_active = true;

-- Представление 3: Воронка продаж по индустриям
CREATE OR REPLACE VIEW vw_sales_funnel AS
WITH funnel_stages AS (
    SELECT
        c.industry,
        d.stage,
        COUNT(*) as deals_count,
        SUM(d.amount) as total_amount,
        AVG(d.amount) as avg_amount,
        COUNT(DISTINCT d.client_id) as unique_clients,
        COUNT(DISTINCT d.created_by) as involved_users,
        MIN(d.created_at) as first_deal_date,
        MAX(d.created_at) as last_deal_date,
        AVG(EXTRACT(EPOCH FROM (d.actual_close_date - d.created_at))/86400)::INTEGER as avg_days_to_close
    FROM deals d
    JOIN clients c ON d.client_id = c.id
    WHERE d.created_at >= NOW() - INTERVAL '1 year'
    GROUP BY c.industry, d.stage
),
industry_totals AS (
    SELECT
        industry,
        SUM(deals_count) as total_deals,
        SUM(total_amount) as total_amount
    FROM funnel_stages
    GROUP BY industry
)
SELECT
    fs.industry,
    fs.stage,
    fs.deals_count,
    fs.total_amount,
    fs.avg_amount,
    fs.unique_clients,
    fs.involved_users,
    ROUND((fs.deals_count::DECIMAL / it.total_deals * 100), 2) as stage_percentage,
    fs.avg_days_to_close,
    fs.first_deal_date,
    fs.last_deal_date,
    it.total_deals as industry_total_deals,
    it.total_amount as industry_total_amount
FROM funnel_stages fs
JOIN industry_totals it ON fs.industry = it.industry
ORDER BY
    fs.industry,
    CASE fs.stage
        WHEN 'Initial Contact' THEN 1
        WHEN 'Qualification' THEN 2
        WHEN 'Proposal' THEN 3
        WHEN 'Negotiation' THEN 4
        WHEN 'Closed Won' THEN 5
        WHEN 'Closed Lost' THEN 6
    END;
