-- ============================================================================
-- УДАЛЕНИЕ ИНДЕКСОВ
-- ============================================================================

-- Удаление индексов таблицы clients
DROP INDEX IF EXISTS idx_clients_industry;
DROP INDEX IF EXISTS idx_clients_status;
DROP INDEX IF EXISTS idx_clients_assigned_to;
DROP INDEX IF EXISTS idx_clients_company_search;
DROP INDEX IF EXISTS idx_clients_company_industry;

-- Удаление индексов таблицы deals
DROP INDEX IF EXISTS idx_deals_client_id;
DROP INDEX IF EXISTS idx_deals_created_by;
DROP INDEX IF EXISTS idx_deals_assigned_to;
DROP INDEX IF EXISTS idx_deals_stage;
DROP INDEX IF EXISTS idx_deals_amount;
DROP INDEX IF EXISTS idx_deals_dates;
DROP INDEX IF EXISTS idx_deals_composite;
DROP INDEX IF EXISTS idx_deals_client_assigned;
DROP INDEX IF EXISTS idx_deals_assigned_stage;
DROP INDEX IF EXISTS idx_deals_stage_amount;

-- Удаление индексов таблицы users
DROP INDEX IF EXISTS idx_users_role_id;
DROP INDEX IF EXISTS idx_users_team_id;
DROP INDEX IF EXISTS idx_users_name;
DROP INDEX IF EXISTS idx_users_email;

-- Удаление индексов таблицы tasks
DROP INDEX IF EXISTS idx_tasks_status;
DROP INDEX IF EXISTS idx_tasks_priority;
DROP INDEX IF EXISTS idx_tasks_due_date;
DROP INDEX IF EXISTS idx_tasks_buyer;
DROP INDEX IF EXISTS idx_tasks_project_manager;
DROP INDEX IF EXISTS idx_tasks_team_lead;
DROP INDEX IF EXISTS idx_tasks_developer;
DROP INDEX IF EXISTS idx_tasks_created_by;
DROP INDEX IF EXISTS idx_tasks_number;
DROP INDEX IF EXISTS idx_tasks_composite;
DROP INDEX IF EXISTS idx_tasks_developer_status;
DROP INDEX IF EXISTS idx_tasks_status_priority_date;

-- Удаление индексов таблицы contacts
DROP INDEX IF EXISTS idx_contacts_client_id;
DROP INDEX IF EXISTS idx_contacts_email;
DROP INDEX IF EXISTS idx_contacts_name;
DROP INDEX IF EXISTS idx_contacts_is_primary;

-- Удаление индексов таблицы products
DROP INDEX IF EXISTS idx_products_is_active;
DROP INDEX IF EXISTS idx_products_price;
DROP INDEX IF EXISTS idx_products_name;

-- Удаление индексов таблицы deal_products
DROP INDEX IF EXISTS idx_deal_products_deal_id;
DROP INDEX IF EXISTS idx_deal_products_product_id;
DROP INDEX IF EXISTS idx_deal_products_amount;

-- Удаление индексов таблицы activities
DROP INDEX IF EXISTS idx_activities_type;
DROP INDEX IF EXISTS idx_activities_created_by;
DROP INDEX IF EXISTS idx_activities_client_id;
DROP INDEX IF EXISTS idx_activities_contact_id;
DROP INDEX IF EXISTS idx_activities_deal_id;
DROP INDEX IF EXISTS idx_activities_dates;
DROP INDEX IF EXISTS idx_activities_client_date;

-- Обновление статистики после удаления индексов
ANALYZE clients;
ANALYZE deals;
ANALYZE users;
ANALYZE tasks;
ANALYZE contacts;
ANALYZE products;
ANALYZE deal_products;
ANALYZE activities;
