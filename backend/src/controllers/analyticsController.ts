import { Request, Response } from 'express';
import pool from '../config/database.js';

interface DatabaseError {
	name: string;
	message: string;
	stack?: string;
	code?: string;
}

// Анализ задач по статусу и приоритету за период
export const getTasksAnalytics = async (req: Request, res: Response) => {
	console.log('getTasksAnalytics called');
	console.log('Query params:', req.query);
	try {
		const { startDate, endDate } = req.query;

		if (!startDate || !endDate) {
			console.log('Missing required dates');
			return res.status(400).json({ message: 'Start date and end date are required' });
		}

		// Сначала проверим наличие задач за период
		const checkQuery = `
            SELECT COUNT(*) as task_count
            FROM tasks t
            WHERE t.created_at BETWEEN $1 AND $2
                AND t.deleted_at IS NULL;
        `;

		const checkResult = await pool.query(checkQuery, [startDate, endDate]);
		console.log('Total tasks in period:', checkResult.rows[0].task_count);

		const query = `
            WITH task_stats AS (
                SELECT
                    COALESCE(t.status, 'not_started') as status,
                    t.priority,
                    COUNT(*) as total_tasks,
                    COUNT(CASE WHEN t.status = 'completed' THEN 1 END) as completed_tasks,
                    AVG(COALESCE(t.estimated_hours, 0)) as avg_estimated_hours,
                    AVG(CASE WHEN t.status = 'completed' THEN COALESCE(t.actual_hours, 0) END) as avg_actual_hours
                FROM tasks t
                WHERE t.created_at BETWEEN $1 AND $2
                    AND t.deleted_at IS NULL
                GROUP BY t.status, t.priority
            )
            SELECT
                status,
                CASE priority
                    WHEN 1 THEN 'low'
                    WHEN 2 THEN 'medium'
                    WHEN 3 THEN 'high'
                    ELSE 'unknown'
                END as priority,
                total_tasks,
                COALESCE(completed_tasks, 0) as completed_tasks,
                CASE
                    WHEN total_tasks > 0 THEN
                        ROUND((COALESCE(completed_tasks, 0)::float / total_tasks * 100)::numeric, 1) || '%'
                    ELSE '0%'
                END as completion_rate,
                ROUND(COALESCE(avg_estimated_hours, 0)::numeric, 1) as avg_estimated_hours,
                ROUND(COALESCE(avg_actual_hours, 0)::numeric, 1) as avg_actual_hours
            FROM task_stats
            ORDER BY
                priority DESC,
                status;
        `;

		console.log('SQL Query:', query);
		const result = await pool.query(query, [startDate, endDate]);
		console.log('Tasks analytics query executed successfully. Row count:', result.rows.length);
		res.json(result.rows);
	} catch (error) {
		const dbError = error as DatabaseError;
		console.error('Error in getTasksAnalytics:', dbError);
		console.error('Error details:', {
			name: dbError.name,
			message: dbError.message,
			stack: dbError.stack,
			code: dbError.code
		});
		res.status(500).json({ message: 'Failed to fetch tasks analytics', error: dbError.message });
	}
};

// Статистика по пользователям и их задачам
export const getUsersWorkload = async (req: Request, res: Response) => {
	console.log('getUsersWorkload called');
	console.log('Query params:', req.query);
	try {
		const { startDate, endDate } = req.query;

		if (!startDate || !endDate) {
			console.log('Missing required dates');
			return res.status(400).json({ message: 'Start date and end date are required' });
		}

		// Сначала проверим наличие задач за период
		const checkQuery = `
            SELECT COUNT(*) as task_count
            FROM tasks t
            WHERE t.created_at BETWEEN $1 AND $2
                AND t.deleted_at IS NULL;
        `;

		const checkResult = await pool.query(checkQuery, [startDate, endDate]);
		console.log('Total tasks in period:', checkResult.rows[0].task_count);

		const query = `
            WITH task_assignments AS (
                -- Объединяем все возможные назначения задач
                SELECT
                    t.id as task_id,
                    t.title,
                    t.status,
                    t.estimated_hours,
                    t.actual_hours,
                    t.created_by as user_id,
                    'creator' as role_in_task
                FROM tasks t
                WHERE t.created_at BETWEEN $1 AND $2
                    AND t.deleted_at IS NULL
                UNION ALL
                SELECT
                    t.id as task_id,
                    t.title,
                    t.status,
                    t.estimated_hours,
                    t.actual_hours,
                    t.developer_id as user_id,
                    'developer' as role_in_task
                FROM tasks t
                WHERE t.created_at BETWEEN $1 AND $2
                    AND t.deleted_at IS NULL
                    AND t.developer_id IS NOT NULL
                UNION ALL
                SELECT
                    t.id as task_id,
                    t.title,
                    t.status,
                    t.estimated_hours,
                    t.actual_hours,
                    t.project_manager_id as user_id,
                    'project_manager' as role_in_task
                FROM tasks t
                WHERE t.created_at BETWEEN $1 AND $2
                    AND t.deleted_at IS NULL
                    AND t.project_manager_id IS NOT NULL
                UNION ALL
                SELECT
                    t.id as task_id,
                    t.title,
                    t.status,
                    t.estimated_hours,
                    t.actual_hours,
                    t.team_lead_id as user_id,
                    'team_lead' as role_in_task
                FROM tasks t
                WHERE t.created_at BETWEEN $1 AND $2
                    AND t.deleted_at IS NULL
                    AND t.team_lead_id IS NOT NULL
                UNION ALL
                SELECT
                    t.id as task_id,
                    t.title,
                    t.status,
                    t.estimated_hours,
                    t.actual_hours,
                    t.integrator_id as user_id,
                    'integrator' as role_in_task
                FROM tasks t
                WHERE t.created_at BETWEEN $1 AND $2
                    AND t.deleted_at IS NULL
                    AND t.integrator_id IS NOT NULL
            ),
            user_stats AS (
                SELECT
                    u.id,
                    CONCAT(u.first_name, ' ', u.last_name) as name,
                    r.name as role,
                    COUNT(DISTINCT ta.task_id) as total_tasks,
                    COUNT(DISTINCT CASE WHEN ta.status = 'completed' THEN ta.task_id END) as completed_tasks,
                    SUM(COALESCE(ta.estimated_hours, 0)) as total_estimated_hours,
                    SUM(CASE WHEN ta.status = 'completed' THEN COALESCE(ta.actual_hours, 0) ELSE 0 END) as total_actual_hours,
                    STRING_AGG(DISTINCT ta.role_in_task, ', ' ORDER BY ta.role_in_task) as roles_in_tasks
                FROM users u
                LEFT JOIN roles r ON u.role_id = r.id
                LEFT JOIN task_assignments ta ON ta.user_id = u.id
                WHERE u.is_active = true
                GROUP BY u.id, u.first_name, u.last_name, r.name
            )
            SELECT
                name,
                role,
                roles_in_tasks,
                total_tasks::integer,
                completed_tasks::integer,
                CASE
                    WHEN total_tasks > 0 THEN
                        ROUND((completed_tasks::float / total_tasks * 100)::numeric, 1) || '%'
                    ELSE '0%'
                END as completion_rate,
                ROUND(total_estimated_hours::numeric, 1) as total_estimated_hours,
                ROUND(total_actual_hours::numeric, 1) as total_actual_hours,
                CASE
                    WHEN total_actual_hours > 0 THEN
                        ROUND((total_estimated_hours::float / total_actual_hours)::numeric, 2)::text
                    ELSE '0'
                END as efficiency_ratio
            FROM user_stats
            WHERE total_tasks > 0
            ORDER BY total_tasks DESC, name ASC;
        `;

		console.log('SQL Query:', query);
		const result = await pool.query(query, [startDate, endDate]);
		console.log('Users workload query executed successfully. Row count:', result.rows.length);
		res.json(result.rows);
	} catch (error) {
		const dbError = error as DatabaseError;
		console.error('Error in getUsersWorkload:', dbError);
		console.error('Error details:', {
			name: dbError.name,
			message: dbError.message,
			stack: dbError.stack,
			code: dbError.code
		});
		res.status(500).json({ message: 'Failed to fetch users workload', error: dbError.message });
	}
};

// Вспомогательные функции для форматирования
const formatStatus = (status: string): string => {
	const statusMap: Record<string, string> = {
		'not_started': 'Не начато',
		'in_progress': 'В работе',
		'completed': 'Завершено'
	};
	return statusMap[status] || status;
};

const formatPriority = (priority: number): string => {
	const priorityMap: Record<number, string> = {
		1: 'Низкий',
		2: 'Средний',
		3: 'Высокий'
	};
	return priorityMap[priority] || String(priority);
};
