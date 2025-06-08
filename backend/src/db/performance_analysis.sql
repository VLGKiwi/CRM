-- Включаем замер времени выполнения
\timing

-- Запрос 1: Анализ продаж по клиентам с подробной информацией
SELECT
    c.company_name,
    c.industry,
    COUNT(d.id) as total_deals,
    SUM(d.amount) as total_amount,
    AVG(d.amount) as avg_deal_amount,
    STRING_AGG(DISTINCT u.first_name || ' ' || u.last_name, ', ') as sales_reps,
    COUNT(DISTINCT t.id) as related_tasks
FROM clients c
LEFT JOIN deals d ON c.id = d.client_id
LEFT JOIN users u ON d.assigned_to = u.id
LEFT JOIN tasks t ON d.assigned_to = t.developer_id  -- Изменённая строка
WHERE d.created_at >= NOW() - INTERVAL '1 year'
GROUP BY c.id, c.company_name, c.industry
HAVING COUNT(d.id) > 0
ORDER BY total_amount DESC;

-- Запрос 2: Сложный анализ эффективности сотрудников
SELECT
    e.first_name || ' ' || e.last_name as employee_name,
    e.position,
    COUNT(DISTINCT d.deal_id) as deals_count,
    SUM(CASE WHEN d.status = 'Closed Won' THEN d.amount ELSE 0 END) as won_amount,
    SUM(CASE WHEN d.status = 'Closed Lost' THEN d.amount ELSE 0 END) as lost_amount,
    COUNT(DISTINCT t.task_id) as tasks_count,
    AVG(CASE WHEN t.status = 'Completed' THEN 1 ELSE 0 END) as task_completion_rate
FROM employees e
LEFT JOIN deals d ON e.employee_id = d.employee_id
LEFT JOIN tasks t ON e.employee_id = t.employee_id
WHERE e.hire_date <= NOW() - INTERVAL '3 months'
GROUP BY e.employee_id, e.first_name, e.last_name, e.position
HAVING COUNT(DISTINCT d.deal_id) > 0
ORDER BY won_amount DESC;

-- Запрос 3: Анализ воронки продаж по индустриям
SELECT
    c.industry,
    d.stage,
    COUNT(d.id) as deals_count,
    SUM(d.amount) as total_amount,
    AVG(d.amount) as avg_amount,
    COUNT(DISTINCT c.id) as unique_clients,
    COUNT(DISTINCT d.created_by) as involved_users
FROM clients c
JOIN deals d ON c.id = d.client_id
GROUP BY c.industry, d.stage
ORDER BY c.industry,
    CASE d.stage
        WHEN 'Initial Contact' THEN 1
        WHEN 'Qualification' THEN 2
        WHEN 'Proposal' THEN 3
        WHEN 'Negotiation' THEN 4
        WHEN 'Closed Won' THEN 5
        WHEN 'Closed Lost' THEN 6
    END;

-- Запрос 4: Сложный поиск клиентов с условиями
SELECT DISTINCT
    c.company_name,
    c.industry,
    COUNT(DISTINCT co.id) as contacts_count,
    STRING_AGG(DISTINCT co.position, ', ') as contact_positions,
    MAX(d.amount) as largest_deal,
    COUNT(DISTINCT d.id) as total_deals
FROM clients c
LEFT JOIN contacts co ON c.id = co.client_id
LEFT JOIN deals d ON c.id = d.client_id
WHERE EXISTS (
    SELECT 1
    FROM deals d2
    WHERE d2.client_id = c.id
    AND d2.stage = 'Closed Won'
)
GROUP BY c.id, c.company_name, c.industry
HAVING COUNT(DISTINCT d.id) >= 2
ORDER BY c.company_name;

-- Запрос 5: Анализ задач и их влияния на сделки
SELECT
    t.status as task_status,
    t.priority,
    COUNT(t.id) as tasks_count,
    COUNT(DISTINCT d.id) as affected_deals,
    AVG(d.amount) as avg_deal_amount,
    STRING_AGG(DISTINCT d.stage, ', ') as deal_stages,
    COUNT(DISTINCT t.created_by) as assigned_users
FROM tasks t
JOIN deals d ON t.deal_id = d.id
WHERE t.due_date BETWEEN NOW() - INTERVAL '6 months' AND NOW() + INTERVAL '1 month'
GROUP BY t.status, t.priority
ORDER BY
    CASE t.priority
        WHEN 'High' THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'Low' THEN 3
    END,
    tasks_count DESC;

-- Запрос 6: Анализ активности клиента
WITH activity_summary AS (
    SELECT
        c.id as client_id,
        c.company_name,
        COUNT(DISTINCT d.id) as deals_count,
        COUNT(DISTINCT t.id) as tasks_count,
        COUNT(DISTINCT a.id) as activities_count,
        SUM(d.amount) FILTER (WHERE d.stage = 'Closed Won') as total_revenue,
        MAX(d.created_at) as last_deal_date,
        MAX(a.created_at) as last_activity_date
    FROM clients c
    LEFT JOIN deals d ON c.id = d.client_id
    LEFT JOIN tasks t ON c.id = t.client_id
    LEFT JOIN activities a ON c.id = a.client_id
    WHERE d.created_at >= NOW() - INTERVAL '1 year'
    OR t.created_at >= NOW() - INTERVAL '1 year'
    OR a.created_at >= NOW() - INTERVAL '1 year'
    GROUP BY c.id, c.company_name
)
SELECT
    company_name,
    deals_count,
    tasks_count,
    activities_count,
    total_revenue,
    last_deal_date,
    last_activity_date,
    CASE
        WHEN last_activity_date >= NOW() - INTERVAL '1 month' THEN 'Active'
        WHEN last_activity_date >= NOW() - INTERVAL '3 months' THEN 'Moderate'
        ELSE 'Inactive'
    END as activity_status
FROM activity_summary
ORDER BY
    CASE
        WHEN last_activity_date >= NOW() - INTERVAL '1 month' THEN 1
        WHEN last_activity_date >= NOW() - INTERVAL '3 months' THEN 2
        ELSE 3
    END,
    total_revenue DESC;
