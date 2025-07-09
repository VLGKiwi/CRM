import { promises as fs } from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import pool from '../config/database.js';
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const SQL_FILES_ORDER = [
    'create_tables.sql',
    'init.sql',
    'insert_data.sql',
    'create_indexes.sql',
];
async function executeSqlFile(filename) {
    try {
        const filePath = path.join(__dirname, filename);
        const sql = await fs.readFile(filePath, 'utf-8');
        console.log(`Executing ${filename}...`);
        await pool.query(sql);
        console.log(`✅ ${filename} executed successfully`);
    }
    catch (error) {
        console.error(`❌ Error executing ${filename}:`, error);
        throw error;
    }
}
async function initializeDatabase() {
    try {
        console.log('Starting database initialization...');
        for (const file of SQL_FILES_ORDER) {
            await executeSqlFile(file);
        }
        console.log('✨ Database initialization completed successfully!');
    }
    catch (error) {
        console.error('Database initialization failed:', error);
        process.exit(1);
    }
    finally {
        await pool.end();
    }
}
initializeDatabase();
