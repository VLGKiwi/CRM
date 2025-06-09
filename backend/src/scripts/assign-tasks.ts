import pool from '../config/database.js';

function getRandomItem<T>(array: T[]): T | undefined {
	if (array.length === 0) return undefined;
	return array[Math.floor(Math.random() * array.length)];
}

async function assignTasks() {
	try {
		// Получаем список пользователей по ролям
		const usersQuery = `
            SELECT
                u.id,
                u.first_name || ' ' || u.last_name as name,
                r.name as role
            FROM users u
            JOIN roles r ON u.role_id = r.id
            WHERE u.is_active = true
            ORDER BY r.name, u.first_name;
        `;

		const usersResult = await pool.query(usersQuery);
		const users = usersResult.rows;

		// Группируем пользователей по ролям
		const developers = users.filter(u => u.role === 'developer');
		const managers = users.filter(u => u.role === 'manager');
		const teamLeads = users.filter(u => u.role === 'team_lead');

		console.log('Found users:');
		console.log('- Developers:', developers.map(d => d.name).join(', '));
		console.log('- Managers:', managers.map(m => m.name).join(', '));
		console.log('- Team Leads:', teamLeads.map(t => t.name).join(', '));

		// Получаем все задачи
		const tasksQuery = `
            SELECT
                id,
                title,
                status,
                created_by
            FROM tasks
            WHERE deleted_at IS NULL;
        `;

		const tasksResult = await pool.query(tasksQuery);
		const tasks = tasksResult.rows;

		console.log('\nFound tasks:', tasks.length);

		// Назначаем исполнителей для каждой задачи
		for (const task of tasks) {
			// Выбираем случайных пользователей для разных ролей
			const developer = getRandomItem(developers);
			const manager = getRandomItem(managers);
			const teamLead = getRandomItem(teamLeads);

			const updateQuery = `
                UPDATE tasks
                SET
                    developer_id = $1,
                    project_manager_id = $2,
                    team_lead_id = $3,
                    updated_at = NOW()
                WHERE id = $4;
            `;

			await pool.query(updateQuery, [
				developer?.id || null,
				manager?.id || null,
				teamLead?.id || null,
				task.id
			]);

			console.log(`\nUpdated task ${task.id} - ${task.title}`);
			console.log(`- Developer: ${developer?.name || 'None'}`);
			console.log(`- Manager: ${manager?.name || 'None'}`);
			console.log(`- Team Lead: ${teamLead?.name || 'None'}`);
		}

		console.log('\nAll tasks have been updated with random assignments');

	} catch (error) {
		console.error('Error assigning tasks:', error);
	} finally {
		await pool.end();
	}
}

assignTasks();
