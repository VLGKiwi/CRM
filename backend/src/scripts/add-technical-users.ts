import pool from '../config/database.js';
import bcrypt from 'bcrypt';

async function addTechnicalUsers() {
	try {
		// Проверяем существующие роли
		const rolesQuery = `
            SELECT id, name
            FROM roles
            WHERE name IN ('developer', 'team_lead');
        `;

		const rolesResult = await pool.query(rolesQuery);
		const roles = rolesResult.rows;

		// Создаем недостающие роли
		if (!roles.find(r => r.name === 'developer')) {
			await pool.query(`
                INSERT INTO roles (name, created_at, updated_at)
                VALUES ('developer', NOW(), NOW());
            `);
			console.log('Created developer role');
		}

		if (!roles.find(r => r.name === 'team_lead')) {
			await pool.query(`
                INSERT INTO roles (name, created_at, updated_at)
                VALUES ('team_lead', NOW(), NOW());
            `);
			console.log('Created team_lead role');
		}

		// Получаем актуальные ID ролей
		const updatedRolesResult = await pool.query(rolesQuery);
		const updatedRoles = updatedRolesResult.rows;

		const developerRoleId = updatedRoles.find(r => r.name === 'developer')?.id;
		const teamLeadRoleId = updatedRoles.find(r => r.name === 'team_lead')?.id;

		// Хешируем пароль
		const salt = await bcrypt.genSalt(10);
		const hashedPassword = await bcrypt.hash('password123', salt);

		// Добавляем разработчиков
		const developers = [
			['Анна', 'Петрова', 'anna@example.com'],
			['Михаил', 'Иванов', 'mikhail@example.com'],
			['Елена', 'Смирнова', 'elena@example.com']
		];

		for (const [firstName, lastName, email] of developers) {
			await pool.query(`
                INSERT INTO users (
                    first_name, last_name, email, password_hash,
                    role_id, is_active, created_at, updated_at
                )
                VALUES ($1, $2, $3, $4, $5, true, NOW(), NOW())
                ON CONFLICT (email) DO NOTHING;
            `, [firstName, lastName, email, hashedPassword, developerRoleId]);

			console.log(`Added/Updated developer: ${firstName} ${lastName}`);
		}

		// Добавляем тимлидов
		const teamLeads = [
			['Павел', 'Козлов', 'pavel@example.com'],
			['Наталья', 'Морозова', 'natalia@example.com']
		];

		for (const [firstName, lastName, email] of teamLeads) {
			await pool.query(`
                INSERT INTO users (
                    first_name, last_name, email, password_hash,
                    role_id, is_active, created_at, updated_at
                )
                VALUES ($1, $2, $3, $4, $5, true, NOW(), NOW())
                ON CONFLICT (email) DO NOTHING;
            `, [firstName, lastName, email, hashedPassword, teamLeadRoleId]);

			console.log(`Added/Updated team lead: ${firstName} ${lastName}`);
		}

		console.log('Technical users have been added successfully');

	} catch (error) {
		console.error('Error adding technical users:', error);
	} finally {
		await pool.end();
	}
}

addTechnicalUsers();
