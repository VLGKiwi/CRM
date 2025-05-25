-- Включаем замер времени выполнения
\timing

-- Запрос 1: Анализ продаж по клиентам с подробной информацией
EXPLAIN ANALYZE
SELECT
    c.company_name,
    c.industry,
    COUNT(d.deal_id) as total_deals,
    SUM(d.amount) as total_amount,
    AVG(d.amount) as avg_deal_amount,
    STRING_AGG(DISTINCT e.first_name || ' ' || e.last_name, ', ') as sales_reps,
    COUNT(DISTINCT t.task_id) as related_tasks
FROM clients c
LEFT JOIN deals d ON c.client_id = d.client_id
LEFT JOIN employees e ON d.employee_id = e.employee_id
LEFT JOIN tasks t ON d.deal_id = t.deal_id
WHERE d.created_at >= NOW() - INTERVAL '1 year'
GROUP BY c.client_id, c.company_name, c.industry
HAVING COUNT(d.deal_id) > 0
ORDER BY total_amount DESC;

-- Запрос 2: Сложный анализ эффективности сотрудников
EXPLAIN ANALYZE
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
EXPLAIN ANALYZE
SELECT
    c.industry,
    d.status,
    COUNT(d.deal_id) as deals_count,
    SUM(d.amount) as total_amount,
    AVG(d.amount) as avg_amount,
    COUNT(DISTINCT c.client_id) as unique_clients,
    COUNT(DISTINCT d.employee_id) as involved_employees
FROM clients c
JOIN deals d ON c.client_id = d.client_id
GROUP BY c.industry, d.status
ORDER BY c.industry,
    CASE d.status
        WHEN 'New' THEN 1
        WHEN 'Qualified' THEN 2
        WHEN 'Proposal' THEN 3
        WHEN 'Negotiation' THEN 4
        WHEN 'Closed Won' THEN 5
        WHEN 'Closed Lost' THEN 6
    END;

-- Запрос 4: Сложный поиск клиентов с условиями
EXPLAIN ANALYZE
SELECT DISTINCT
    c.company_name,
    c.industry,
    c.annual_revenue,
    COUNT(DISTINCT co.contact_id) as contacts_count,
    STRING_AGG(DISTINCT co.position, ', ') as contact_positions,
    MAX(d.amount) as largest_deal,
    COUNT(DISTINCT d.deal_id) as total_deals
FROM clients c
LEFT JOIN contacts co ON c.client_id = co.client_id
LEFT JOIN deals d ON c.client_id = d.client_id
WHERE
    c.annual_revenue >= 1000000
    AND EXISTS (
        SELECT 1
        FROM deals d2
        WHERE d2.client_id = c.client_id
        AND d2.status = 'Closed Won'
    )
GROUP BY c.client_id, c.company_name, c.industry, c.annual_revenue
HAVING COUNT(DISTINCT d.deal_id) >= 2
ORDER BY c.annual_revenue DESC;

-- Запрос 5: Анализ задач и их влияния на сделки
EXPLAIN ANALYZE
SELECT
    t.status as task_status,
    t.priority,
    COUNT(t.task_id) as tasks_count,
    COUNT(DISTINCT d.deal_id) as affected_deals,
    AVG(d.amount) as avg_deal_amount,
    STRING_AGG(DISTINCT d.status, ', ') as deal_statuses,
    COUNT(DISTINCT e.employee_id) as assigned_employees
FROM tasks t
JOIN deals d ON t.deal_id = d.deal_id
JOIN employees e ON t.employee_id = e.employee_id
WHERE
    t.due_date BETWEEN NOW() - INTERVAL '6 months' AND NOW() + INTERVAL '1 month'
GROUP BY t.status, t.priority
ORDER BY
    CASE t.priority
        WHEN 'Urgent' THEN 1
        WHEN 'High' THEN 2
        WHEN 'Medium' THEN 3
        WHEN 'Low' THEN 4
    END,
    tasks_count DESC;
