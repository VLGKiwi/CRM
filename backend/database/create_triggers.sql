-- Триггер 1: Логирование изменений в сделках
CREATE OR REPLACE FUNCTION log_deal_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        -- Логируем изменение статуса
        IF NEW.stage <> OLD.stage THEN
            INSERT INTO activities (
                type,
                subject,
                description,
                created_by,
                created_at,
                client_id,
                deal_id
            ) VALUES (
                'Deal Stage Change',
                'Deal Stage Updated: ' || NEW.title,
                'Stage changed from ' || OLD.stage || ' to ' || NEW.stage,
                NEW.updated_by,
                NOW(),
                NEW.client_id,
                NEW.id
            );
        END IF;

        -- Логируем изменение суммы
        IF NEW.amount <> OLD.amount THEN
            INSERT INTO activities (
                type,
                subject,
                description,
                created_by,
                created_at,
                client_id,
                deal_id
            ) VALUES (
                'Deal Amount Change',
                'Deal Amount Updated: ' || NEW.title,
                'Amount changed from ' || OLD.amount || ' ' || OLD.currency ||
                ' to ' || NEW.amount || ' ' || NEW.currency,
                NEW.updated_by,
                NOW(),
                NEW.client_id,
                NEW.id
            );
        END IF;

        -- Логируем изменение ответственного
        IF NEW.assigned_to <> OLD.assigned_to THEN
            INSERT INTO activities (
                type,
                subject,
                description,
                created_by,
                created_at,
                client_id,
                deal_id
            ) VALUES (
                'Deal Assignment Change',
                'Deal Reassigned: ' || NEW.title,
                'Assigned to user ' || NEW.assigned_to,
                NEW.updated_by,
                NOW(),
                NEW.client_id,
                NEW.id
            );
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER deal_changes_trigger
AFTER UPDATE ON deals
FOR EACH ROW
EXECUTE FUNCTION log_deal_changes();

-- Триггер 2: Автоматическое обновление статистики клиента
CREATE OR REPLACE FUNCTION update_client_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        -- Обновляем статистику клиента
        UPDATE clients
        SET
            total_deals = (
                SELECT COUNT(*)
                FROM deals
                WHERE client_id = NEW.client_id
            ),
            total_revenue = (
                SELECT COALESCE(SUM(amount), 0)
                FROM deals
                WHERE client_id = NEW.client_id
                AND stage = 'Closed Won'
            ),
            last_activity_date = NOW(),
            updated_at = NOW()
        WHERE id = NEW.client_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER client_stats_trigger
AFTER INSERT OR UPDATE ON deals
FOR EACH ROW
EXECUTE FUNCTION update_client_stats();

-- Триггер 3: Автоматическое создание задач при создании сделки
CREATE OR REPLACE FUNCTION create_deal_tasks()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- Создаем задачу для первичного контакта
        INSERT INTO tasks (
            title,
            description,
            due_date,
            priority,
            status,
            created_by,
            assigned_to,
            client_id,
            deal_id
        ) VALUES (
            'Initial Contact for ' || NEW.title,
            'Schedule initial meeting with the client to discuss ' || NEW.title,
            CURRENT_DATE + INTERVAL '2 days',
            'High',
            'New',
            NEW.created_by,
            NEW.assigned_to,
            NEW.client_id,
            NEW.id
        );

        -- Создаем задачу для подготовки предложения
        INSERT INTO tasks (
            title,
            description,
            due_date,
            priority,
            status,
            created_by,
            assigned_to,
            client_id,
            deal_id
        ) VALUES (
            'Prepare Proposal for ' || NEW.title,
            'Prepare and send commercial proposal for ' || NEW.title,
            CURRENT_DATE + INTERVAL '5 days',
            'Medium',
            'New',
            NEW.created_by,
            NEW.assigned_to,
            NEW.client_id,
            NEW.id
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER deal_tasks_trigger
AFTER INSERT ON deals
FOR EACH ROW
EXECUTE FUNCTION create_deal_tasks();

-- Триггер 4: Проверка и обновление статуса задачи
CREATE OR REPLACE FUNCTION validate_task_status()
RETURNS TRIGGER AS $$
BEGIN
    -- Проверяем, что задача не может быть завершена без указания фактических часов
    IF NEW.status = 'Completed' AND NEW.actual_hours IS NULL THEN
        RAISE EXCEPTION 'Cannot complete task without specifying actual hours';
    END IF;

    -- Автоматически устанавливаем статус "Delayed" если прошла дата выполнения
    IF NEW.status NOT IN ('Completed', 'Cancelled') AND
       NEW.due_date < CURRENT_DATE THEN
        NEW.status := 'Delayed';
    END IF;

    -- Логируем изменение статуса
    IF TG_OP = 'UPDATE' AND OLD.status <> NEW.status THEN
        INSERT INTO activities (
            type,
            subject,
            description,
            created_by,
            created_at,
            client_id,
            deal_id
        ) VALUES (
            'Task Status Change',
            'Task Status Updated: ' || NEW.title,
            'Status changed from ' || OLD.status || ' to ' || NEW.status,
            NEW.updated_by,
            NOW(),
            NEW.client_id,
            NEW.deal_id
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER task_status_trigger
BEFORE INSERT OR UPDATE ON tasks
FOR EACH ROW
EXECUTE FUNCTION validate_task_status();
