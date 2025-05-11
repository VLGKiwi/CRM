# Структура базы данных CRM-системы

## Стратегия хранения и масштабирования

### Ожидаемые объемы данных (год)
- Users: ~1000 записей
- Tasks: ~100,000 записей
- Messages: ~1,000,000 записей
- Notifications: ~2,000,000 записей
- Files: ~50GB

### Стратегия масштабирования
1. Партиционирование
   - Messages: помесячно
   - Notifications: помесячно
   - TaskHistory: поквартально
   - AuditLog: помесячно

2. Архивация
   - Архивация сообщений старше 1 года
   - Архивация уведомлений старше 6 месяцев
   - Архивация истории задач старше 2 лет
   - Перенос в хранилище с меньшей стоимостью

3. Репликация
   - Master-Slave репликация
   - Чтение с реплик
   - Запись только в master
   - Автоматическое переключение при сбоях

### Стратегия кэширования
1. Уровень приложения
   - Кэширование частых запросов
   - Кэширование справочников
   - Инвалидация по событиям

2. Уровень базы данных
   - Материализованные представления
   - Регулярное обновление статистики
   - Оптимизация планов запросов

## Таблицы

### Users
- id (PK, UUID)
- email (VARCHAR, UNIQUE)
- password_hash (VARCHAR)
- first_name (VARCHAR)
- last_name (VARCHAR)
- role_id (FK)
- team_id (FK)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
- last_login (TIMESTAMP)
- is_active (BOOLEAN)
- two_factor_enabled (BOOLEAN)
- two_factor_secret (VARCHAR, ENCRYPTED)
- settings (JSONB)

### Roles
- id (PK)
- name (VARCHAR)
- description (TEXT)
- permissions (JSONB)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
- is_system (BOOLEAN)

### Teams
- id (PK)
- name (VARCHAR)
- department_id (FK)
- leader_id (FK)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
- settings (JSONB)
- is_active (BOOLEAN)

### Departments
- id (PK)
- name (VARCHAR)
- head_id (FK)
- parent_id (FK, self-reference)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
- settings (JSONB)

### Tasks
- id (PK)
- title (VARCHAR)
- description (TEXT)
- status (VARCHAR)
- priority (INTEGER)
- buyer_id (FK)
- project_manager_id (FK)
- team_lead_id (FK)
- integrator_id (FK)
- developer_id (FK)
- created_by (FK)
- task_number (VARCHAR, UNIQUE within buyer)
- final_link (VARCHAR)
- tags (ARRAY)
- metadata (JSONB)
- due_date (TIMESTAMP)
- estimated_hours (FLOAT)
- actual_hours (FLOAT)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
- deleted_at (TIMESTAMP, soft delete)

### TaskHistory
- id (PK)
- task_id (FK)
- previous_status (VARCHAR)
- new_status (VARCHAR)
- changed_by (FK)
- comment (TEXT)
- created_at (TIMESTAMP)
- metadata (JSONB)

### TaskFiles
- id (PK)
- task_id (FK)
- file_path (VARCHAR)
- file_name (VARCHAR)
- file_size (INTEGER)
- mime_type (VARCHAR)
- version (INTEGER)
- uploaded_by (FK)
- created_at (TIMESTAMP)
- is_deleted (BOOLEAN)
- checksum (VARCHAR)

### Chats
- id (PK)
- task_id (FK)
- type (VARCHAR)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
- is_active (BOOLEAN)
- metadata (JSONB)

### Messages
- id (PK)
- chat_id (FK)
- sender_id (FK)
- content (TEXT)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
- is_read (BOOLEAN)
- read_by (JSONB)
- attachments (JSONB)
- is_system (BOOLEAN)

### Notifications
- id (PK)
- user_id (FK)
- type (VARCHAR)
- content (JSONB)
- is_read (BOOLEAN)
- created_at (TIMESTAMP)
- read_at (TIMESTAMP)
- expires_at (TIMESTAMP)
- priority (INTEGER)

### Funnels
- id (PK)
- name (VARCHAR)
- type (VARCHAR)
- owner_id (FK)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
- settings (JSONB)
- is_active (BOOLEAN)

### FunnelStages
- id (PK)
- funnel_id (FK)
- name (VARCHAR)
- order (INTEGER)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
- settings (JSONB)

### UserVisibility
- id (PK)
- user_id (FK)
- visible_to_user_id (FK)
- created_at (TIMESTAMP)
- created_by (FK)
- expires_at (TIMESTAMP)

### AuditLog
- id (PK)
- user_id (FK)
- action (VARCHAR)
- entity_type (VARCHAR)
- entity_id (UUID)
- changes (JSONB)
- ip_address (VARCHAR)
- user_agent (VARCHAR)
- created_at (TIMESTAMP)

## Индексы
- users(email)
- tasks(task_number)
- tasks(buyer_id)
- tasks(project_manager_id)
- tasks(created_at)
- messages(chat_id, created_at)
- notifications(user_id, is_read)
- audit_log(entity_type, entity_id)
- task_history(task_id, created_at)
- user_visibility(user_id, visible_to_user_id)

## Партиционирование
1. **Messages** - партиционирование по дате создания (помесячно)
2. **Notifications** - партиционирование по дате создания (помесячно)
3. **AuditLog** - партиционирование по дате создания (помесячно)
4. **TaskHistory** - партиционирование по дате создания (поквартально)

## Ограничения
- Уникальный email пользователя
- Уникальный номер задачи в рамках байера
- Каскадное удаление связанных записей
- Проверка статусов задач
- Проверка прав доступа к воронкам
- Валидация дат (created_at <= updated_at)
- Проверка циклических ссылок в departments

## Триггеры
1. **Задачи**:
   - Автоматическое создание номера задачи
   - Логирование изменений статуса задачи
   - Обновление времени последнего изменения
   - Создание записи в истории при изменении

2. **Уведомления**:
   - Создание уведомлений при изменениях
   - Очистка старых уведомлений
   - Обновление счетчиков непрочитанных

3. **Аудит**:
   - Логирование критических изменений
   - Запись информации о пользователе

4. **Файлы**:
   - Обновление версий файлов
   - Проверка контрольных сумм
   - Очистка удаленных файлов

## Политики безопасности
1. Шифрование чувствительных данных
2. Row Level Security для разграничения доступа
3. Политики доступа на уровне БД
4. Аудит критических операций

## Оптимизация производительности

### Индексы
1. Основные индексы:
   - users(email)
   - tasks(task_number)
   - tasks(buyer_id, created_at)
   - tasks(project_manager_id, status)
   - tasks(created_at)
   - messages(chat_id, created_at)
   - notifications(user_id, is_read, created_at)
   - audit_log(entity_type, entity_id)
   - task_history(task_id, created_at)
   - user_visibility(user_id, visible_to_user_id)
   - task_files(task_id, version)

2. Составные индексы:
   - tasks(status, priority, due_date)
   - messages(chat_id, sender_id, created_at)
   - notifications(user_id, type, is_read)

### Материализованные представления
1. task_statistics
   - Статистика по задачам
   - Обновление раз в час
   - Используется для отчетов

2. user_workload
   - Текущая загрузка пользователей
   - Обновление каждые 15 минут
   - Используется для распределения задач

## Безопасность данных

### Row Level Security
```sql
-- Пример RLS для Tasks
CREATE POLICY task_access_policy ON tasks
    USING (
        -- Проджект видит все
        (current_user_role() = 'project_manager') OR
        -- Тим-лид видит задачи своей команды
        (current_user_role() = 'team_lead' AND team_id = current_user_team()) OR
        -- Медиабайер видит только свои задачи
        (current_user_role() = 'media_buyer' AND buyer_id = current_user_id()) OR
        -- Интегратор видит назначенные ему задачи
        (current_user_role() = 'integrator' AND integrator_id = current_user_id())
    );
```

### Шифрование данных
1. Данные в покое:
   - Шифрование sensitive полей
   - Шифрование бэкапов
   - Шифрование файлов

2. Данные в движении:
   - SSL/TLS для всех соединений
   - Шифрование в приложении
   - Защищенные каналы репликации

## Мониторинг и обслуживание

### Мониторинг производительности
1. Метрики:
   - Время выполнения запросов
   - Использование индексов
   - Размер таблиц и индексов
   - Статистика блокировок

2. Алерты:
   - Долгие запросы
   - Высокая нагрузка
   - Проблемы репликации
   - Нехватка места

### Обслуживание
1. Регулярные задачи:
   - VACUUM ANALYZE (ежедневно)
   - Обновление статистики (ежедневно)
   - Проверка целостности (еженедельно)
   - Архивация данных (ежемесячно)

2. Резервное копирование:
   - Полный бэкап (ежедневно)
   - Инкрементальный бэкап (каждые 6 часов)
   - Проверка восстановления (еженедельно)
   - Географическая репликация

## Миграции и обновления

### Стратегия миграции
1. Подготовка:
   - Создание плана миграции
   - Тестирование на копии данных
   - Подготовка rollback плана

2. Выполнение:
   - В нерабочее время
   - С минимальным простоем
   - С возможностью отката
   - С проверкой данных

### Обновления схемы
1. Правила:
   - Только аддитивные изменения
   - Поэтапное удаление
   - Версионирование схемы
   - Документирование изменений

2. Процесс:
   - Создание миграции
   - Тестирование на dev
   - Проверка на staging
   - Применение на prod
