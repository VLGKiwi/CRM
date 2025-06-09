import pool from '../config/database.js';
import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

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
