import { Pool } from 'pg';
import dotenv from 'dotenv';

dotenv.config();

// Debug database configuration
console.log('Database configuration:');
console.log('DB_USER:', process.env.DB_USER || 'postgres');
console.log('DB_HOST:', process.env.DB_HOST || 'localhost');
console.log('DB_NAME:', process.env.DB_NAME || 'crm_db');
console.log('DB_PORT:', process.env.DB_PORT || '5432');

const pool = new Pool({
	user: process.env.DB_USER || 'postgres',
	host: process.env.DB_HOST || 'localhost',
	database: process.env.DB_NAME || 'crm_db',
	password: process.env.DB_PASSWORD || 'postgres',
	port: parseInt(process.env.DB_PORT || '5432'),
});

// Test database connection
pool.query('SELECT NOW()', (err, res) => {
	if (err) {
		console.error('Database connection error:', err);
	} else {
		console.log('Database connected successfully');
	}
});

export default pool;
