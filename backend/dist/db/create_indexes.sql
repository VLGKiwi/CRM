-- Индексы для таблицы clients
CREATE INDEX IF NOT EXISTS idx_clients_industry ON clients(industry);
CREATE INDEX IF NOT EXISTS idx_clients_status ON clients(status);
CREATE INDEX IF NOT EXISTS idx_clients_assigned_to ON clients(assigned_to);
CREATE INDEX IF NOT EXISTS idx_clients_company_search ON clients(company_name text_pattern_ops);
CREATE INDEX IF NOT EXISTS idx_clients_company_industry ON clients(company_name, industry);

-- Индексы для таблицы deals
CREATE INDEX IF NOT EXISTS idx_deals_client_id ON deals(client_id);
CREATE INDEX IF NOT EXISTS idx_deals_created_by ON deals(created_by);
CREATE INDEX IF NOT EXISTS idx_deals_assigned_to ON deals(assigned_to);
CREATE INDEX IF NOT EXISTS idx_deals_stage ON deals(stage);
CREATE INDEX IF NOT EXISTS idx_deals_amount ON deals(amount DESC);
CREATE INDEX IF NOT EXISTS idx_deals_dates ON deals(expected_close_date, actual_close_date);
CREATE INDEX IF NOT EXISTS idx_deals_composite ON deals(client_id, stage, amount);
CREATE INDEX IF NOT EXISTS idx_deals_client_assigned ON deals(client_id, assigned_to);
CREATE INDEX IF NOT EXISTS idx_deals_assigned_stage ON deals(assigned_to, stage, amount);
CREATE INDEX IF NOT EXISTS idx_deals_stage_amount ON deals(stage, amount);

-- Индексы для таблицы users
CREATE INDEX IF NOT EXISTS idx_users_role_id ON users(role_id);
CREATE INDEX IF NOT EXISTS idx_users_team_id ON users(team_id);
CREATE INDEX IF NOT EXISTS idx_users_name ON users(first_name, last_name);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email text_pattern_ops);

-- Индексы для таблицы tasks
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);
CREATE INDEX IF NOT EXISTS idx_tasks_priority ON tasks(priority);
CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON tasks(due_date);
CREATE INDEX IF NOT EXISTS idx_tasks_buyer ON tasks(buyer_id);
CREATE INDEX IF NOT EXISTS idx_tasks_project_manager ON tasks(project_manager_id);
CREATE INDEX IF NOT EXISTS idx_tasks_team_lead ON tasks(team_lead_id);
CREATE INDEX IF NOT EXISTS idx_tasks_developer ON tasks(developer_id);
CREATE INDEX IF NOT EXISTS idx_tasks_created_by ON tasks(created_by);
CREATE INDEX IF NOT EXISTS idx_tasks_number ON tasks(task_number);
CREATE INDEX IF NOT EXISTS idx_tasks_composite ON tasks(status, priority, due_date);
CREATE INDEX IF NOT EXISTS idx_tasks_developer_status ON tasks(developer_id, status);
CREATE INDEX IF NOT EXISTS idx_tasks_status_priority_date ON tasks(status, priority, due_date);

-- Индексы для таблицы contacts
CREATE INDEX IF NOT EXISTS idx_contacts_client_id ON contacts(client_id);
CREATE INDEX IF NOT EXISTS idx_contacts_email ON contacts(email text_pattern_ops);
CREATE INDEX IF NOT EXISTS idx_contacts_name ON contacts(first_name, last_name);
CREATE INDEX IF NOT EXISTS idx_contacts_is_primary ON contacts(is_primary);

-- Индексы для таблицы products
CREATE INDEX IF NOT EXISTS idx_products_is_active ON products(is_active);
CREATE INDEX IF NOT EXISTS idx_products_price ON products(price);
CREATE INDEX IF NOT EXISTS idx_products_name ON products(name text_pattern_ops);

-- Индексы для таблицы deal_products
CREATE INDEX IF NOT EXISTS idx_deal_products_deal_id ON deal_products(deal_id);
CREATE INDEX IF NOT EXISTS idx_deal_products_product_id ON deal_products(product_id);
CREATE INDEX IF NOT EXISTS idx_deal_products_amount ON deal_products(total_amount DESC);

-- Индексы для таблицы activities
CREATE INDEX IF NOT EXISTS idx_activities_type ON activities(type);
CREATE INDEX IF NOT EXISTS idx_activities_created_by ON activities(created_by);
CREATE INDEX IF NOT EXISTS idx_activities_client_id ON activities(client_id);
CREATE INDEX IF NOT EXISTS idx_activities_contact_id ON activities(contact_id);
CREATE INDEX IF NOT EXISTS idx_activities_deal_id ON activities(deal_id);
CREATE INDEX IF NOT EXISTS idx_activities_dates ON activities(start_time, end_time);
CREATE INDEX IF NOT EXISTS idx_activities_client_date ON activities(client_id, created_at);

-- Анализ таблиц после создания индексов
ANALYZE clients;
ANALYZE deals;
ANALYZE users;
ANALYZE tasks;
ANALYZE contacts;
ANALYZE products;
ANALYZE deal_products;
ANALYZE activities;
