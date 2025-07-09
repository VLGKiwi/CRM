import pg from 'pg';
import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const pool = new pg.Pool({
    user: process.env.DB_USER || 'postgres',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'crm_db',
    password: process.env.DB_PASSWORD || 'qwerty',
    port: parseInt(process.env.DB_PORT || '5432'),
});

const applyMigrations = async () => {
    try {
        // Читаем файл миграции
        const migrationPath = path.join(__dirname, 'migrations', '002_add_refresh_token.sql');
        const migrationSQL = await fs.readFile(migrationPath, 'utf-8');

        // Применяем миграцию
        await pool.query(migrationSQL);

        console.log('✅ Migration applied successfully');
    } catch (error) {
        console.error('Error applying migration:', error);
    } finally {
        await pool.end();
    }
};

applyMigrations();
