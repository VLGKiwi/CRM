import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { db } from './index.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function initializeDatabase() {
  try {
    const createTablesSql = fs.readFileSync(path.join(__dirname, 'create_tables.sql'), 'utf8');
    const insertDataSql = fs.readFileSync(path.join(__dirname, 'insert_data.sql'), 'utf8');
    const createIndexesSql = fs.readFileSync(path.join(__dirname, 'create_indexes.sql'), 'utf8');


    console.log('Creating tables...');
    const createTableQueries = createTablesSql
      .split(';')
      .map(query => query.trim())
      .filter(query => query);

    for (const query of createTableQueries) {
      try {
        await db.query(query);
        console.log('Created table:', query.substring(0, 50) + '...');
      } catch (error) {
        if (!error.message.includes('already exists') && !error.message.includes('уже существует')) {
          throw error;
        }
      }
    }

    // Выполняем создание индексов
    console.log('Creating indexes...');
    const createIndexQueries = createIndexesSql
      .split(';')
      .map(query => query.trim())
      .filter(query => query);

    for (const query of createIndexQueries) {
      try {
        await db.query(query);
        console.log('Created index:', query.substring(0, 50) + '...');
      } catch (error) {
        if (!error.message.includes('already exists') && !error.message.includes('уже существует')) {
          throw error;
        }
      }
    }

    // Выполняем вставку данных
    console.log('Inserting initial data...');
    const insertQueries = insertDataSql
      .split(';')
      .map(query => query.trim())
      .filter(query => query);

    for (const query of insertQueries) {
      try {
        await db.query(query);
        console.log('Inserted data:', query.substring(0, 50) + '...');
      } catch (error) {
        if (!error.message.includes('duplicate key') && !error.message.includes('уже существует')) {
          throw error;
        }
      }
    }

    console.log('Database initialization completed successfully');
  } catch (error) {
    console.error('Error initializing database:', error);
    process.exit(1);
  } finally {
    await db.end();
  }
}

initializeDatabase();
