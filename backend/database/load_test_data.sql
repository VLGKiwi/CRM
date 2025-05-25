-- Загрузка данных из CSV файлов
\timing

-- Загрузка ролей
COPY roles(name, description)
FROM '/path/to/data/roles.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- Загрузка команд
COPY teams(name, description)
FROM '/path/to/data/teams.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- Загрузка пользователей
COPY users(id, email, password_hash, first_name, last_name, role_id, team_id, is_active)
FROM '/path/to/data/users.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- Загрузка клиентов
COPY clients(company_name, industry, website, phone, address, city, country, postal_code, assigned_to, status)
FROM '/path/to/data/clients.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- Загрузка контактов
COPY contacts(client_id, first_name, last_name, position, email, phone, mobile, is_primary)
FROM '/path/to/data/contacts.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- Загрузка продуктов
COPY products(name, description, price, currency, is_active)
FROM '/path/to/data/products.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- Загрузка сделок
COPY deals(client_id, title, description, amount, currency, stage, probability,
           expected_close_date, actual_close_date, created_by, assigned_to)
FROM '/path/to/data/deals.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- Загрузка продуктов в сделках
COPY deal_products(deal_id, product_id, quantity, price, discount_percentage, total_amount)
FROM '/path/to/data/deal_products.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- Загрузка задач
COPY tasks(title, description, due_date, priority, status, buyer_id,
           project_manager_id, team_lead_id, integrator_id, developer_id,
           created_by, task_number, final_link, tags, estimated_hours, actual_hours)
FROM '/path/to/data/tasks.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- Загрузка активностей
COPY activities(type, subject, description, start_time, end_time, location,
                result, created_by, client_id, contact_id, deal_id)
FROM '/path/to/data/activities.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- Анализ таблиц после загрузки
ANALYZE roles;
ANALYZE teams;
ANALYZE users;
ANALYZE clients;
ANALYZE contacts;
ANALYZE products;
ANALYZE deals;
ANALYZE deal_products;
ANALYZE tasks;
ANALYZE activities;
