-- Заполнение таблицы ролей
INSERT INTO roles (name, description, created_at, updated_at)
VALUES
    ('admin', 'Администратор системы', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('manager', 'Менеджер', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('sales', 'Менеджер по продажам', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('support', 'Сотрудник поддержки', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (name) DO UPDATE SET
    description = EXCLUDED.description,
    updated_at = CURRENT_TIMESTAMP;

-- Заполнение таблицы команд
INSERT INTO teams (name, description, created_at, updated_at)
VALUES
    ('Продажи', 'Отдел продаж', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Поддержка', 'Отдел поддержки', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Разработка', 'разработки', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Маркетинг', 'Отдел', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (name) DO UPDATE SET
    description = EXCLUDED.description,
    updated_at = CURRENT_TIMESTAMP;

-- Заполнение таблицы пользователей
INSERT INTO users (id, password_hash, email, first_name, last_name, role_id, team_id, created_at, updated_at, last_login, is_active, two_factor_enabled, two_factor_secret)
VALUES
    ('00000000-0000-0000-0000-000000000001', '$2a$10$XFE0DcAdWRMsUVEMPZxXU.K.6Oxe5kHww3lNMlYRKXqHNyPu4uGCa', 'admin@example.com', 'Админ', 'Системный', 1, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE, FALSE, NULL),
    ('00000000-0000-0000-0000-000000000002', '$2a$10$XFE0DcAdWRMsUVEMPZxXU.K.6Oxe5kHww3lNMlYRKXqHNyPu4uGCa', 'manager1@example.com', 'сергей', 'Петров', 2, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE, FALSE, NULL),
    ('00000000-0000-0000-0000-000000000003', '$2a$10$XFE0DcAdWRMsUVEMPZxXU.K.6Oxe5kHww3lNMlYRKXqHNyPu4uGCa', 'manager2@example.com', 'Иван', 'Сидорова', 2, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE, FALSE, NULL),
    ('00000000-0000-0000-0000-000000000004', '$2a$10$XFE0DcAdWRMsUVEMPZxXU.K.6Oxe5kHww3lNMlYRKXqHNyPu4uGCa', 'sales1@example.com', 'Алексей', 'Иванов', 3, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE, FALSE, NULL),
    ('00000000-0000-0000-0000-000000000005', '$2a$10$XFE0DcAdWRMsUVEMPZxXU.K.6Oxe5kHww3lNMlYRKXqHNyPu4uGCa', 'sales2@example.com', 'Мария', 'Кузнецова', 3, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE, FALSE, NULL),
    ('00000000-0000-0000-0000-000000000006', '$2a$10$XFE0DcAdWRMsUVEMPZxXU.K.6Oxe5kHww3lNMlYRKXqHNyPu4uGCa', 'sales3@example.com', 'Дмитрий', 'Смирнов', 3, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE, FALSE, NULL),
    ('00000000-0000-0000-0000-000000000007', '$2a$10$XFE0DcAdWRMsUVEMPZxXU.K.6Oxe5kHww3lNMlYRKXqHNyPu4uGCa', 'support1@example.com', 'Ольга', 'Новикова', 4, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE, FALSE, NULL),
    ('00000000-0000-0000-0000-000000000008', '$2a$10$XFE0DcAdWRMsUVEMPZxXU.K.6Oxe5kHww3lNMlYRKXqHNyPu4uGCa', 'support2@example.com', 'Сергей', 'Морозов', 4, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE, FALSE, NULL),
    ('00000000-0000-0000-0000-000000000009', '$2a$10$XFE0DcAdWRMsUVEMPZxXU.K.6Oxe5kHww3lNMlYRKXqHNyPu4uGCa', 'inactive@example.com', 'Неактивный', 'Пользователь', 3, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE, FALSE, NULL),
    ('00000000-0000-0000-0000-000000000010', '$2a$10$XFE0DcAdWRMsUVEMPZxXU.K.6Oxe5kHww3lNMlYRKXqHNyPu4uGCa', 'newhire@example.com', 'Новый', 'Сотрудник', 4, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL, TRUE, FALSE, NULL);

-- Заполнение таблицы клиентов
INSERT INTO clients (company_name, industry, website, phone, address, city, country, postal_code, created_at, updated_at, assigned_to, status)
VALUES
    ('ООО "ТехноПром"', 'Manufacturing', 'technoprom.ru', '+7 (495) 123-4567', 'ул. Промышленная, 42', 'Москва', 'Россия', '123456', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000002', 'active'),
    ('АО "ИнфоСистемы"', 'IT', 'infosystems.ru', '+7 (812) 765-4321', 'пр. Невский, 30', 'Санкт-Петербург', 'Россия', '198765', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000003', 'active'),
    ('ООО "СтройМастер"', 'Construction', 'stroymaster.ru', '+7 (343) 555-1234', 'ул. Строителей, 15', 'Екатеринбург', 'Россия', '620000', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000004', 'active'),
    ('ЗАО "ФинансГрупп"', 'Finance', 'financegroup.ru', '+7 (383) 222-3333', 'ул. Банковская, 7', 'Новосибирск', 'Россия', '630000', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000005', 'active'),
    ('ООО "МедТехника"', 'Healthcare', 'medtech.ru', '+7 (863) 444-5555', 'пр. Медицинский, 10', 'Ростов-на-Дону', 'Россия', '344000', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000006', 'active'),
    ('ИП Иванов А.А.', 'Retail', 'ivanov-shop.ru', '+7 (351) 777-8888', 'ул. Торговая, 22', 'Челябинск', 'Россия', '454000', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000002', 'active'),
    ('ООО "ЭкоФерма"', 'Agriculture', 'ecofarm.ru', '+7 (473) 999-0000', 'ул. Сельская, 5', 'Воронеж', 'Россия', '394000', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000003', 'active'),
    ('ООО "ТрансЛогистик"', 'Logistics', 'translogistic.ru', '+7 (846) 111-2222', 'ул. Транспортная, 18', 'Самара', 'Россия', '443000', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000004', 'active'),
    ('ООО "ЭнергоСбыт"', 'Energy', 'energosbyt.ru', '+7 (391) 333-4444', 'пр. Энергетиков, 33', 'Красноярск', 'Россия', '660000', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000005', 'lead'),
    ('ООО "ИнтернетРешения"', 'IT', 'netsolutions.ru', '+7 (831) 666-7777', 'ул. Цифровая, 11', 'Нижний Новгород', 'Россия', '603000', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000006', 'prospect'),
    ('ООО "АвтоДилер"', 'Automotive', 'autodealer.ru', '+7 (843) 888-9999', 'пр. Автомобильный, 25', 'Казань', 'Россия', '420000', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000002', 'inactive'),
    ('ООО "ОбразованиеПлюс"', 'Education', 'eduplus.ru', '+7 (4212) 222-1111', 'ул. Учебная, 9', 'Хабаровск', 'Россия', '680000', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000003', 'active');

-- Заполнение таблицы контактов
INSERT INTO contacts (client_id, first_name, last_name, position, email, phone, mobile, is_primary, created_at, updated_at)
VALUES
    (1, 'Александр', 'Петров', 'Генеральный директор', 'petrov@technoprom.ru', '+7 (495) 123-4567', '+7 (916) 111-2222', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (1, 'Наталья', 'Смирнова', 'Финансовый директор', 'smirnova@technoprom.ru', '+7 (495) 123-4568', '+7 (916) 222-3333', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (2, 'Игорь', 'Васильев', 'CTO', 'vasiliev@infosystems.ru', '+7 (812) 765-4321', '+7 (921) 333-4444', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (2, 'Елена', 'Козлова', 'HR-директор', 'kozlova@infosystems.ru', '+7 (812) 765-4322', '+7 (921) 444-5555', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (3, 'Дмитрий', 'Николаев', 'Директор', 'nikolaev@stroymaster.ru', '+7 (343) 555-1234', '+7 (912) 555-6666', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (4, 'Ольга', 'Федорова', 'CEO', 'fedorova@financegroup.ru', '+7 (383) 222-3333', '+7 (913) 666-7777', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (5, 'Сергей', 'Медведев', 'Директор', 'medvedev@medtech.ru', '+7 (863) 444-5555', '+7 (918) 777-8888', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (6, 'Андрей', 'Иванов', 'Владелец', 'ivanov@ivanov-shop.ru', '+7 (351) 777-8888', '+7 (919) 888-9999', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (7, 'Мария', 'Соколова', 'Директор', 'sokolova@ecofarm.ru', '+7 (473) 999-0000', '+7 (920) 999-0001', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (8, 'Виктор', 'Лебедев', 'Логистический директор', 'lebedev@translogistic.ru', '+7 (846) 111-2222', '+7 (927) 111-2223', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (9, 'Анна', 'Кузнецова', 'Коммерческий директор', 'kuznetsova@energosbyt.ru', '+7 (391) 333-4444', '+7 (923) 333-4445', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (10, 'Павел', 'Морозов', 'CEO', 'morozov@netsolutions.ru', '+7 (831) 666-7777', '+7 (929) 666-7778', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (11, 'Екатерина', 'Волкова', 'Директор по продажам', 'volkova@autodealer.ru', '+7 (843) 888-9999', '+7 (917) 888-9990', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (12, 'Михаил', 'Соловьев', 'Директор', 'soloviev@eduplus.ru', '+7 (4212) 222-1111', '+7 (914) 222-1112', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Заполнение таблицы продуктов
INSERT INTO products (name, description, price, currency, is_active, created_at, updated_at)
VALUES
    ('CRM Basic', 'Базовая версия CRM-системы', 15000.00, 'RUB', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('CRM Professional', 'Профессиональная версия CRM-системы', 35000.00, 'RUB', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('CRM Enterprise', 'Корпоративная версия CRM-системы', 75000.00, 'RUB', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Модуль аналитики', 'Дополнительный модуль для аналитики данных', 12000.00, 'RUB', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Модуль интеграции', 'Модуль для интеграции с внешними системами', 18000.00, 'RUB', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Модуль автоматизации', 'Модуль для автоматизации бизнес-процессов', 25000.00, 'RUB', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Техническая поддержка (1 год)', 'Годовая техническая поддержка', 20000.00, 'RUB', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Обучение персонала', 'Обучение сотрудников работе с системой', 30000.00, 'RUB', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Настройка системы', 'Индивидуальная настройка системы', 40000.00, 'USD', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Мобильное приложение', 'Мобильное приложение для CRM', 15000.00, 'RUB', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Заполнение таблицы сделок
INSERT INTO deals (client_id, title, description, amount, currency, stage, probability, expected_close_date, actual_close_date, created_at, updated_at, created_by, assigned_to)
VALUES
    (1, 'Внедрение CRM Enterprise', 'Внедрение корпоративной версии CRM-системы', 15000.00, 'RUB', 'won', 100, '2023-06-15', '2023-06-10', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002'),
    (2, 'Обновление до CRM Professional', 'Обновление существующей системы до профессиональной версии', 50000.00, 'RUB', 'negotiation', 75, '2023-08-20', NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000004'),
    (3, 'Техническая поддержка', 'Продление технической поддержки на год', 20000.00, 'RUB', 'proposal', 90, '2023-07-30', NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000006'),
    (4, 'Внедрение CRM Basic', 'Внедрение базовой версии CRM-системы', 25000.00, 'RUB', 'won', 100, '2023-05-10', '2023-05-05', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000003'),
    (5, 'Модуль аналитики и интеграции', 'Внедрение дополнительных модулей', 30000.00, 'RUB', 'negotiation', 60, '2023-09-15', NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000005'),
    (6, 'Обучение персонала', 'Обучение сотрудников работе с CRM', 30000.00, 'RUB', 'won', 100, '2023-04-20', '2023-04-18', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000002'),
    (7, 'Комплексное решение', 'Внедрение CRM Professional с модулями', 80000.00, 'RUB', 'proposal', 85, '2023-10-10', NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000004'),
    (8, 'Мобильное приложение', 'Разработка мобильного приложения для CRM', 35000.00, 'RUB', 'lead', 30, '2023-11-30', NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000006'),
    (9, 'Пробная версия CRM', 'Тестирование CRM Basic', 0.00, 'RUB', 'lead', 20, '2023-12-15', NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000003'),
    (10, 'Настройка системы', 'Индивидуальная настройка CRM Enterprise', 60000.00, 'RUB', 'negotiation', 70, '2023-09-25', NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000005'),
    (11, 'Интеграция с 1С', 'Интеграция CRM с 1С', 45000.00, 'RUB', 'lost', 0, '2023-07-05', '2023-07-10', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000002'),
    (12, 'Обновление системы', 'Обновление до последней версии', 15000.00, 'RUB', 'won', 100, '2023-06-30', '2023-06-28', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000004');

-- Заполнение таблицы связи между сделками и продуктами
INSERT INTO deal_products (deal_id, product_id, quantity, price, discount_percentage, total_amount, created_at)
VALUES
    (1, 3, 1, 75000.00, 0.00, 75000.00, CURRENT_TIMESTAMP),
    (1, 7, 1, 20000.00, 0.00, 20000.00, CURRENT_TIMESTAMP),
    (1, 8, 1, 30000.00, 0.00, 30000.00, CURRENT_TIMESTAMP),
    (1, 9, 1, 40000.00, 15.00, 34000.00, CURRENT_TIMESTAMP),
    (2, 2, 1, 35000.00, 0.00, 35000.00, CURRENT_TIMESTAMP),
    (2, 4, 1, 12000.00, 0.00, 12000.00, CURRENT_TIMESTAMP),
    (2, 10, 1, 15000.00, 10.00, 13500.00, CURRENT_TIMESTAMP),
    (3, 7, 1, 20000.00, 0.00, 20000.00, CURRENT_TIMESTAMP),
    (4, 1, 1, 15000.00, 0.00, 15000.00, CURRENT_TIMESTAMP),
    (4, 8, 1, 30000.00, 20.00, 24000.00, CURRENT_TIMESTAMP),
    (5, 4, 1, 12000.00, 0.00, 12000.00, CURRENT_TIMESTAMP),
    (5, 5, 1, 18000.00, 0.00, 18000.00, CURRENT_TIMESTAMP),
    (6, 8, 1, 30000.00, 0.00, 30000.00, CURRENT_TIMESTAMP),
    (7, 2, 1, 35000.00, 0.00, 35000.00, CURRENT_TIMESTAMP),
    (7, 4, 1, 12000.00, 0.00, 12000.00, CURRENT_TIMESTAMP),
    (7, 5, 1, 18000.00, 0.00, 18000.00, CURRENT_TIMESTAMP),
    (7, 6, 1, 25000.00, 10.00, 22500.00, CURRENT_TIMESTAMP),
    (8, 10, 1, 15000.00, 0.00, 15000.00, CURRENT_TIMESTAMP),
    (8, 5, 1, 18000.00, 0.00, 18000.00, CURRENT_TIMESTAMP),
    (10, 3, 1, 75000.00, 20.00, 60000.00, CURRENT_TIMESTAMP),
    (11, 5, 1, 18000.00, 0.00, 18000.00, CURRENT_TIMESTAMP),
    (11, 6, 1, 25000.00, 0.00, 25000.00, CURRENT_TIMESTAMP),
    (12, 7, 1, 20000.00, 25.00, 15000.00, CURRENT_TIMESTAMP);

-- Заполнение таблицы задач
INSERT INTO tasks (title, description, due_date, priority, status, buyer_id, project_manager_id, team_lead_id, integrator_id, developer_id, created_by, task_number, final_link, tags, metadata, estimated_hours, actual_hours, created_at, updated_at, deleted_at)
VALUES
    ('Подготовить коммерческое предложение', 'Подготовить КП для ООО "ИнфоСистемы"', '2023-07-25 12:00:00', 1, 'in_progress', NULL, NULL, NULL, NULL, NULL, '00000000-0000-0000-0000-000000000001', 'TASK-2023-001', NULL, ARRAY['КП', 'Продажи'], '{"client_id": 2, "deal_id": 2}', 2.5, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
    ('Провести демонстрацию системы', 'Демонстрация возможностей CRM для ООО "СтройМастер"', '2023-07-20 15:00:00', 2, 'not_started', NULL, NULL, NULL, NULL, NULL, '00000000-0000-0000-0000-000000000003', 'TASK-2023-002', NULL, ARRAY['Демо', 'Продажи'], '{"client_id": 3, "deal_id": 3}', 3.0, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
    ('Согласовать договор', 'Согласование договора с юристами ЗАО "ФинансГрупп"', '2023-08-05 10:00:00', 1, 'not_started', NULL, NULL, NULL, NULL, NULL, '00000000-0000-0000-0000-000000000005', 'TASK-2023-003', NULL, ARRAY['Договор', 'Юристы'], '{"client_id": 4}', 4.0, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
    ('Установить обновление', 'Установка обновления для ООО "МедТехника"', '2023-07-15 09:00:00', 2, 'completed', NULL, NULL, NULL, NULL, NULL, '00000000-0000-0000-0000-000000000002', 'TASK-2023-004', 'https://update-log.example.com/12345', ARRAY['Обновление', 'Техподдержка'], '{"client_id": 5, "deal_id": 5}', 2.0, 1.5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
    ('Обучить новых пользователей', 'Обучение новых сотрудников ИП Иванов А.А.', '2023-07-30 14:00:00', 3, 'not_started', NULL, NULL, NULL, NULL, NULL, '00000000-0000-0000-0000-000000000004', 'TASK-2023-005', NULL, ARRAY['Обучение', 'Клиент'], '{"client_id": 6, "deal_id": 6}', 8.0, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
    ('Исправить ошибку в отчетах', 'Исправление ошибки в модуле отчетности для ООО "ЭкоФерма"', '2023-07-10 11:00:00', 0, 'in_progress', NULL, NULL, NULL, NULL, NULL, '00000000-0000-0000-0000-000000000006', 'TASK-2023-006', NULL, ARRAY['Баг', 'Отчеты'], '{"client_id": 7, "deal_id": 7}', 4.0, 2.5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
    ('Настроить интеграцию с 1С', 'Настройка интеграции CRM с 1С для ООО "ТрансЛогистик"', '2023-08-15 13:00:00', 1, 'not_started', NULL, NULL, NULL, NULL, NULL, '00000000-0000-0000-0000-000000000003', 'TASK-2023-007', NULL, ARRAY['Интеграция', '1С'], '{"client_id": 8, "deal_id": 8}', 16.0, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
    ('Подготовить презентацию', 'Подготовка презентации для ООО "ЭнергоСбыт"', '2023-07-18 16:00:00', 2, 'in_progress', NULL, NULL, NULL, NULL, NULL, '00000000-0000-0000-0000-000000000005', 'TASK-2023-008', NULL, ARRAY['Презентация', 'Маркетинг'], '{"client_id": 9, "deal_id": 9}', 5.0, 3.0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
    ('Провести аудит системы', 'Аудит текущей CRM-системы ООО "ИнтернетРешения"', '2023-08-10 10:00:00', 2, 'not_started', NULL, NULL, NULL, NULL, NULL, '00000000-0000-0000-0000-000000000002', 'TASK-2023-009', NULL, ARRAY['Аудит'], '{"client_id": 10}', 8.0, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
    ('Подготовить отчет о внедрении', 'Подготовка отчета о результатах внедрения для ООО "ТехноПром"', '2023-07-05 09:00:00', 3, 'completed', NULL, NULL, NULL, NULL, NULL, '00000000-0000-0000-0000-000000000004', 'TASK-2023-010', NULL, ARRAY['Отчет'], '{"client_id": 1, "deal_id": 1}', 4.0, 4.0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

-- Заполнение таблицы активностей
INSERT INTO activities (type, subject, description, start_time, end_time, location, result, created_at, updated_at, created_by, client_id, contact_id, deal_id)
VALUES
    ('call', 'Первичный звонок', 'Первичный звонок потенциальному клиенту', '2023-06-15 10:00:00', '2023-06-15 10:15:00', NULL, 'Клиент заинтересован, назначена встреча', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000004', 2, 3, 2),
    ('meeting', 'Презентация продукта', 'Презентация возможностей CRM-системы', '2023-06-20 14:00:00', '2023-06-20 15:30:00', 'Офис клиента', 'Клиент запросил коммерческое предложение', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000006', 3, 5, 3),
    ('email', 'Отправка КП', 'Отправка коммерческого предложения', '2023-06-25 09:30:00', NULL, NULL, 'КП отправлено, ожидаем ответа', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000002', 4, 6, NULL),
    ('call', 'Обсуждение условий', 'Обсуждение условий сотрудничества', '2023-06-30 11:00:00', '2023-06-30 11:20:00', NULL, 'Согласованы основные условия', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000003', 5, 7, 5),
    ('meeting', 'Подписание договора', 'Встреча для подписания договора', '2023-07-05 13:00:00', '2023-07-05 14:00:00', 'Наш офис', 'Договор подписан', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000005', 6, 8, 6),
    ('note', 'Внутренняя заметка', 'Заметка о специфических требованиях клиента', NULL, NULL, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000004', 7, 9, 7),
    ('call', 'Техническая консультация', 'Консультация по техническим вопросам', '2023-07-10 15:00:00', '2023-07-10 15:45:00', NULL, 'Даны разъяснения по всем вопросам', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000006', 8, 10, 8),
    ('email', 'Отправка инструкций', 'Отправка инструкций по использованию системы', '2023-07-15 10:00:00', NULL, NULL, 'Инструкции отправлены', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000002', 9, 11, 9),
    ('meeting', 'Обучение персонала', 'Обучение сотрудников работе с CRM', '2023-07-20 09:00:00', '2023-07-20 17:00:00', 'Офис клиента', 'Обучение проведено успешно', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000003', 10, 12, 10),
    ('call', 'Контроль удовлетворенности', 'Звонок для проверки удовлетворенности клиента', '2023-07-25 14:00:00', '2023-07-25 14:15:00', NULL, 'Клиент доволен системой', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '00000000-0000-0000-0000-000000000005', 1, 1, 1);
