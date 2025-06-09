import pool from '../config/database.js';

async function checkAssignments() {
	try {
		const query = `
            WITH task_assignments AS (
                -- Объединяем все возможные назначения задач
                SELECT
                    t.id as task_id,
                    t.title,
                    t.status,
                    t.estimated_hours,
                    t.actual_hours,
                    CASE
                        WHEN t.developer_id IS NOT NULL THEN t.developer_id
                        WHEN t.project_manager_id IS NOT NULL THEN t.project_manager_id
                        WHEN t.team_lead_id IS NOT NULL THEN t.team_lead_id
                        WHEN t.integrator_id IS NOT NULL THEN t.integrator_id
                        ELSE t.created_by
                    END as user_id,
                    CASE
                        WHEN t.developer_id IS NOT NULL THEN 'developer'
                        WHEN t.project_manager_id IS NOT NULL THEN 'project_manager'
                        WHEN t.team_lead_id IS NOT NULL THEN 'team_lead'
                        WHEN t.integrator_id IS NOT NULL THEN 'integrator'
                        ELSE 'creator'
                    END as role_in_task
                FROM tasks t
                WHERE t.created_at BETWEEN '2025-06-08' AND '2025-06-09'
                    AND t.deleted_at IS NULL
            )
            SELECT
                ta.task_id,
                ta.title,
                ta.status,
                ta.role_in_task,
                u.first_name || ' ' || u.last_name as user_name,
                r.name as user_role
            FROM task_assignments ta
            LEFT JOIN users u ON ta.user_id = u.id
            LEFT JOIN roles r ON u.role_id = r.id
            ORDER BY ta.task_id;
        `;

		const result = await pool.query(query);
		console.log('Task assignments:', JSON.stringify(result.rows, null, 2));

	} catch (error) {
		console.error('Error checking assignments:', error);
	} finally {
		await pool.end();
	}
}

checkAssignments();
