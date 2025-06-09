import pool from '../config/database.js';

async function checkUsers() {
	try {
		const result = await pool.query(`
            SELECT
                u.email,
                u.first_name,
                u.last_name,
                r.name as role,
                u.is_active
            FROM users u
            LEFT JOIN roles r ON u.role_id = r.id
        `);

		console.log('Existing users:');
		console.log(JSON.stringify(result.rows, null, 2));
	} catch (error) {
		console.error('Error checking users:', error);
	} finally {
		await pool.end();
	}
}

checkUsers();
