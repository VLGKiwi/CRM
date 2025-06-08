import pool from '../config/database.js';
import bcrypt from 'bcryptjs';

const updateAdminPassword = async () => {
	try {
		const password = 'admin123';
		const hashedPassword = await bcrypt.hash(password, 10);

		const result = await pool.query(
			'UPDATE users SET password_hash = $1 WHERE email = $2 RETURNING *',
			[hashedPassword, 'admin@example.com']
		);

		if (result.rowCount > 0) {
			console.log('✅ Password updated successfully for admin@example.com');
			console.log('New credentials:');
			console.log('Email: admin@example.com');
			console.log('Password:', password);
		} else {
			console.log('❌ Admin user not found');
		}
	} catch (error) {
		console.error('Error updating password:', error);
	} finally {
		await pool.end();
	}
};

updateAdminPassword();
