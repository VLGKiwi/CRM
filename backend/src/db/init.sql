-- Создание базы данных (если не существует)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'crm_db') THEN
        CREATE DATABASE crm_db;
    END IF;
END $$;

\c crm_db;

-- Создание таблицы пользователей
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Создание индекса для email
CREATE INDEX IF NOT EXISTS users_email_idx ON users(email);

-- Вставка тестового пользователя
INSERT INTO users (email, password_hash, name)
VALUES ('test@example.com', 'password', 'Test User')
ON CONFLICT (email) DO NOTHING;
