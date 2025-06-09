import { promises as fs } from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import pool from '../config/database.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function executeSqlFile(filename: string) {
	try {
		const filePath = path.join(__dirname, filename);
		const sql = await fs.readFile(filePath, 'utf-8');
		console.log(`Executing ${filename}...`);
		await pool.query(sql);
		console.log(`✅ ${filename} executed successfully`);
	} catch (error) {
		console.error(`❌ Error executing ${filename}:`, error);
		throw error;
	}
}

async function seedDatabase() {
	try {
		console.log('Starting database seeding...');
		await executeSqlFile('test_tasks.sql');
		console.log('✨ Database seeding completed successfully!');
	} catch (error) {
		console.error('Database seeding failed:', error);
		process.exit(1);
	} finally {
		await pool.end();
	}
}

seedDatabase();
