-- Добавление колонки refresh_token
ALTER TABLE users ADD COLUMN IF NOT EXISTS refresh_token TEXT;
