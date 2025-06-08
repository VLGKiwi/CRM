-- ============================================================================
-- ПРИМЕРЫ ВЫЗОВА ПРЕДСТАВЛЕНИЙ
-- ============================================================================

-- 1. Детальная информация о клиентах
-- Показывает подробную информацию о клиентах, включая количество сделок,
-- общую выручку, контакты и последнюю активность
SELECT * FROM vw_client_details
WHERE industry = 'Technology'
ORDER BY total_revenue DESC
LIMIT 5;

-- Пример с дополнительной фильтрацией по активности
SELECT
    company_name,
    industry,
    total_deals,
    total_revenue,
    last_activity_date
FROM vw_client_details
WHERE total_revenue > 100000
AND last_activity_date >= NOW() - INTERVAL '30 days'
ORDER BY last_activity_date DESC;

-- Группировка по индустриям
SELECT
    industry,
    COUNT(*) as clients_count,
    SUM(total_revenue) as industry_revenue,
    AVG(total_deals) as avg_deals_per_client
FROM vw_client_details
GROUP BY industry
ORDER BY industry_revenue DESC;

-- 2. Эффективность пользователей
-- Отображает KPI сотрудников, включая количество сделок,
-- процент успешных закрытий и выполнение задач
SELECT * FROM vw_user_performance
WHERE total_deals > 0
ORDER BY total_revenue DESC
LIMIT 5;

-- Анализ эффективности по месяцам
SELECT
    user_name,
    DATE_TRUNC('month', deal_date) as month,
    COUNT(deal_id) as deals_count,
    SUM(deal_amount) as monthly_revenue,
    AVG(conversion_rate) as avg_conversion
FROM vw_user_performance
WHERE deal_date >= NOW() - INTERVAL '6 months'
GROUP BY user_name, DATE_TRUNC('month', deal_date)
ORDER BY month DESC, monthly_revenue DESC;

-- Сравнение производительности команд
SELECT
    team_name,
    COUNT(DISTINCT user_id) as team_size,
    SUM(total_revenue) as team_revenue,
    AVG(conversion_rate) as team_conversion,
    COUNT(DISTINCT deal_id) as total_team_deals
FROM vw_user_performance
GROUP BY team_name
ORDER BY team_revenue DESC;

-- 3. Воронка продаж по индустриям
-- Анализирует конверсию и эффективность продаж
-- в разрезе индустрий и стадий сделок
SELECT * FROM vw_sales_funnel
WHERE industry = 'Technology'
ORDER BY stage_percentage DESC;

-- Анализ воронки по месяцам
SELECT
    DATE_TRUNC('month', deal_created_at) as month,
    stage,
    COUNT(*) as deals_count,
    SUM(amount) as stage_amount,
    AVG(conversion_rate) as avg_conversion
FROM vw_sales_funnel
WHERE deal_created_at >= NOW() - INTERVAL '6 months'
GROUP BY DATE_TRUNC('month', deal_created_at), stage
ORDER BY month DESC, stage;

-- Сравнение конверсии между индустриями
SELECT
    industry,
    stage,
    COUNT(*) as deals_in_stage,
    SUM(amount) as total_amount,
    AVG(conversion_rate) as industry_conversion,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY industry) as stage_percentage
FROM vw_sales_funnel
GROUP BY industry, stage
ORDER BY industry, stage_percentage DESC;

-- 4. Анализ активности по клиентам
-- Детальный отчет по всем активностям с клиентами
SELECT
    cd.company_name,
    cd.industry,
    COUNT(DISTINCT a.id) as activities_count,
    STRING_AGG(DISTINCT a.type, ', ') as activity_types,
    MAX(a.created_at) as last_activity,
    COUNT(DISTINCT d.id) as related_deals
FROM vw_client_details cd
LEFT JOIN activities a ON cd.client_id = a.client_id
LEFT JOIN deals d ON cd.client_id = d.client_id
WHERE a.created_at >= NOW() - INTERVAL '90 days'
GROUP BY cd.company_name, cd.industry
HAVING COUNT(DISTINCT a.id) > 0
ORDER BY activities_count DESC;

-- 5. Прогноз продаж
-- Анализ потенциальных сделок и прогноз выручки
SELECT
    DATE_TRUNC('month', expected_close_date) as month,
    COUNT(*) as deals_count,
    SUM(amount) as potential_revenue,
    SUM(amount * probability / 100) as weighted_forecast
FROM vw_sales_funnel
WHERE stage NOT IN ('Closed Won', 'Closed Lost')
AND expected_close_date >= CURRENT_DATE
GROUP BY DATE_TRUNC('month', expected_close_date)
ORDER BY month;
