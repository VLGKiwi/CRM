-- Процедура 1: Создание нового клиента с контактами
CREATE OR REPLACE PROCEDURE create_client_with_contacts(
    p_company_name VARCHAR,
    p_industry VARCHAR,
    p_website VARCHAR,
    p_phone VARCHAR,
    p_address VARCHAR,
    p_city VARCHAR,
    p_country VARCHAR,
    p_postal_code VARCHAR,
    p_assigned_to UUID,
    p_contacts JSONB
) LANGUAGE plpgsql AS $$
DECLARE
    v_client_id UUID;
    v_contact JSONB;
BEGIN
    -- Создаем клиента
    INSERT INTO clients (
        company_name, industry, website, phone, address,
        city, country, postal_code, assigned_to, status
    ) VALUES (
        p_company_name, p_industry, p_website, p_phone, p_address,
        p_city, p_country, p_postal_code, p_assigned_to, 'Active'
    ) RETURNING id INTO v_client_id;

    -- Создаем контакты
    FOR v_contact IN SELECT * FROM jsonb_array_elements(p_contacts)
    LOOP
        INSERT INTO contacts (
            first_name, last_name, email, phone, position,
            client_id, created_by
        ) VALUES (
            v_contact->>'first_name',
            v_contact->>'last_name',
            v_contact->>'email',
            v_contact->>'phone',
            v_contact->>'position',
            v_client_id,
            p_assigned_to
        );
    END LOOP;
END;
$$;

-- Процедура 2: Создание новой сделки с продуктами
CREATE OR REPLACE PROCEDURE create_deal_with_products(
    p_client_id UUID,
    p_title VARCHAR,
    p_description TEXT,
    p_amount DECIMAL,
    p_currency VARCHAR,
    p_stage VARCHAR,
    p_probability INTEGER,
    p_expected_close_date DATE,
    p_created_by UUID,
    p_assigned_to UUID,
    p_products JSONB
) LANGUAGE plpgsql AS $$
DECLARE
    v_deal_id UUID;
    v_product JSONB;
BEGIN
    -- Создаем сделку
    INSERT INTO deals (
        client_id, title, description, amount, currency,
        stage, probability, expected_close_date, created_by, assigned_to
    ) VALUES (
        p_client_id, p_title, p_description, p_amount, p_currency,
        p_stage, p_probability, p_expected_close_date, p_created_by, p_assigned_to
    ) RETURNING id INTO v_deal_id;

    -- Добавляем продукты к сделке
    FOR v_product IN SELECT * FROM jsonb_array_elements(p_products)
    LOOP
        INSERT INTO deal_products (
            deal_id, product_id, quantity, price
        ) VALUES (
            v_deal_id,
            (v_product->>'product_id')::UUID,
            (v_product->>'quantity')::INTEGER,
            (v_product->>'price')::DECIMAL
        );
    END LOOP;
END;
$$;

-- Процедура 3: Обновление статуса задачи с логированием
CREATE OR REPLACE PROCEDURE update_task_status(
    p_task_id UUID,
    p_new_status VARCHAR,
    p_actual_hours DECIMAL,
    p_updated_by UUID
) LANGUAGE plpgsql AS $$
DECLARE
    v_old_status VARCHAR;
    v_task_title VARCHAR;
BEGIN
    -- Получаем текущий статус
    SELECT status, title INTO v_old_status, v_task_title
    FROM tasks
    WHERE id = p_task_id;

    -- Обновляем статус и фактические часы
    UPDATE tasks
    SET
        status = p_new_status,
        actual_hours = COALESCE(actual_hours, 0) + p_actual_hours,
        updated_at = NOW()
    WHERE id = p_task_id;

    -- Логируем изменение в activities
    INSERT INTO activities (
        type,
        subject,
        description,
        created_by,
        created_at
    ) VALUES (
        'Task Status Change',
        'Task Status Updated: ' || v_task_title,
        'Status changed from ' || v_old_status || ' to ' || p_new_status ||
        '. Added ' || p_actual_hours || ' hours.',
        p_updated_by,
        NOW()
    );
END;
$$;

-- Процедура 4: Массовое обновление назначенных пользователей
CREATE OR REPLACE PROCEDURE reassign_clients_and_deals(
    p_old_user_id UUID,
    p_new_user_id UUID
) LANGUAGE plpgsql AS $$
DECLARE
    v_affected_clients INTEGER;
    v_affected_deals INTEGER;
BEGIN
    -- Обновляем клиентов
    UPDATE clients
    SET
        assigned_to = p_new_user_id,
        updated_at = NOW()
    WHERE assigned_to = p_old_user_id
    RETURNING COUNT(*) INTO v_affected_clients;

    -- Обновляем сделки
    UPDATE deals
    SET
        assigned_to = p_new_user_id,
        updated_at = NOW()
    WHERE assigned_to = p_old_user_id
    RETURNING COUNT(*) INTO v_affected_deals;

    -- Логируем изменение
    INSERT INTO activities (
        type,
        subject,
        description,
        created_by,
        created_at
    ) VALUES (
        'Mass Reassignment',
        'Clients and Deals Reassigned',
        'Reassigned ' || v_affected_clients || ' clients and ' ||
        v_affected_deals || ' deals from user ' || p_old_user_id ||
        ' to user ' || p_new_user_id,
        p_new_user_id,
        NOW()
    );
END;
$$;
