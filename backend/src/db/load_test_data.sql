-- Очистка таблиц
TRUNCATE roles, teams, users, clients, contacts, products, deals, deal_products, tasks, activities CASCADE;

-- Загрузка ролей
COPY roles(id, name, description)
FROM 'C:/Users/TemaV/Desktop/github/CRM/backend/data/roles.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- Загрузка команд
COPY teams(id, name, description)
FROM 'C:/Users/TemaV/Desktop/github/CRM/backend/data/teams.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- Загрузка пользователей
COPY users(id, email, password_hash, first_name, last_name, role_id, team_id, is_active, two_factor_enabled)
FROM 'C:/Users/TemaV/Desktop/github/CRM/backend/data/users.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- Загрузка клиентов
COPY clients(id, company_name, industry, website, phone, address, city, country, postal_code, assigned_to, status)
FROM 'C:/Users/TemaV/Desktop/github/CRM/backend/data/clients.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- Загрузка контактов
COPY contacts(id, client_id, first_name, last_name, position, email, phone, mobile, is_primary)
FROM 'C:/Users/TemaV/Desktop/github/CRM/backend/data/contacts.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- Загрузка продуктов
COPY products(id, name, description, price, currency, is_active)
FROM 'C:/Users/TemaV/Desktop/github/CRM/backend/data/products.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- Загрузка сделок
COPY deals(id, client_id, title, description, amount, currency, stage, probability,
           expected_close_date, actual_close_date, created_by, assigned_to)
FROM 'C:/Users/TemaV/Desktop/github/CRM/backend/data/deals.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- Загрузка продуктов в сделках
COPY deal_products(id, deal_id, product_id, quantity, price, discount_percentage, total_amount)
FROM 'C:/Users/TemaV/Desktop/github/CRM/backend/data/deal_products.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- Загрузка задач
COPY tasks(id, title, description, due_date, priority, status, buyer_id, project_manager_id,
           team_lead_id, integrator_id, developer_id, created_by, task_number, final_link,
           tags, estimated_hours, actual_hours)
FROM 'C:/Users/TemaV/Desktop/github/CRM/backend/data/tasks.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- Загрузка активностей
COPY activities(id, type, subject, description, start_time, end_time, location, result,
               created_by, client_id, contact_id, deal_id)
FROM 'C:/Users/TemaV/Desktop/github/CRM/backend/data/activities.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- Обновление последовательностей
SELECT setval('clients_id_seq', (SELECT MAX(id) FROM clients));
SELECT setval('contacts_id_seq', (SELECT MAX(id) FROM contacts));
SELECT setval('products_id_seq', (SELECT MAX(id) FROM products));
SELECT setval('deals_id_seq', (SELECT MAX(id) FROM deals));
SELECT setval('deal_products_id_seq', (SELECT MAX(id) FROM deal_products));
SELECT setval('tasks_id_seq', (SELECT MAX(id) FROM tasks));
SELECT setval('activities_id_seq', (SELECT MAX(id) FROM activities));
SELECT setval('roles_id_seq', (SELECT MAX(id) FROM roles));
SELECT setval('teams_id_seq', (SELECT MAX(id) FROM teams));

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
