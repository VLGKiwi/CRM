-- Очистка таблицы задач
TRUNCATE TABLE tasks CASCADE;

-- Заполнение таблицы задач тестовыми данными
INSERT INTO tasks (
    title,
    description,
    due_date,
    priority,
    status,
    created_by,
    task_number,
    tags,
    estimated_hours,
    actual_hours,
    created_at,
    updated_at
) VALUES
    (
        'Разработка главной страницы',
        'Создать адаптивный дизайн главной страницы',
        CURRENT_TIMESTAMP + INTERVAL '7 days',
        2,
        'not_started',
        '00000000-0000-0000-0000-000000000001',
        'TASK-2023-001',
        ARRAY['Frontend', 'UI/UX'],
        8.0,
        NULL,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'Настройка базы данных',
        'Оптимизация индексов и запросов',
        CURRENT_TIMESTAMP + INTERVAL '3 days',
        1,
        'in_progress',
        '00000000-0000-0000-0000-000000000001',
        'TASK-2023-002',
        ARRAY['Backend', 'Database'],
        4.0,
        2.5,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'Тестирование API',
        'Написать интеграционные тесты для API',
        CURRENT_TIMESTAMP + INTERVAL '5 days',
        1,
        'not_started',
        '00000000-0000-0000-0000-000000000001',
        'TASK-2023-003',
        ARRAY['Testing', 'API'],
        6.0,
        NULL,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'Исправление багов в авторизации',
        'Исправить проблемы с токенами JWT',
        CURRENT_TIMESTAMP + INTERVAL '1 day',
        0,
        'in_progress',
        '00000000-0000-0000-0000-000000000001',
        'TASK-2023-004',
        ARRAY['Bug', 'Security'],
        3.0,
        1.5,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'Документация API',
        'Создать Swagger документацию для API',
        CURRENT_TIMESTAMP + INTERVAL '10 days',
        3,
        'not_started',
        '00000000-0000-0000-0000-000000000001',
        'TASK-2023-005',
        ARRAY['Documentation', 'API'],
        5.0,
        NULL,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    );
