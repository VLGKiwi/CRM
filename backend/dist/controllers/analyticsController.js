import pool from '../config/database.js';
// Анализ задач по статусу и приоритету за период
export const getTasksAnalytics = async (req, res) => {
    console.log('getTasksAnalytics called');
    console.log('Query params:', req.query);
    try {
        const { startDate, endDate } = req.query;
        if (!startDate || !endDate) {
            console.log('Missing required dates');
            return res.status(400).json({ message: 'Start date and end date are required' });
        }
        // Validate date format
        const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
        if (!dateRegex.test(startDate) || !dateRegex.test(endDate)) {
            return res.status(400).json({ message: 'Invalid date format. Use YYYY-MM-DD' });
        }
        // Сначала проверим наличие задач за период
        const checkQuery = `
            SELECT COUNT(*) as task_count
            FROM tasks t
            WHERE t.created_at::date BETWEEN $1::date AND $2::date
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
                WHERE t.created_at::date BETWEEN $1::date AND $2::date
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
    }
    catch (error) {
        const dbError = error;
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
export const getUsersWorkload = async (req, res) => {
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
    }
    catch (error) {
        const dbError = error;
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
const formatStatus = (status) => {
    const statusMap = {
        'not_started': 'Не начато',
        'in_progress': 'В работе',
        'completed': 'Завершено'
    };
    return statusMap[status] || status;
};
const formatPriority = (priority) => {
    const priorityMap = {
        1: 'Низкий',
        2: 'Средний',
        3: 'Высокий'
    };
    return priorityMap[priority] || String(priority);
};
// Аналитика: количество задач по приоритету
export const getTasksByPriority = async (req, res) => {
    try {
        const { startDate, endDate, priority } = req.query;
        console.log('getTasksByPriority params:', { startDate, endDate, priority });
        let where = 'WHERE deleted_at IS NULL';
        const params = [];
        let idx = 1;
        if (startDate && typeof startDate === 'string' && startDate.trim() !== '') {
            where += ` AND created_at::date >= $${idx++}::date`;
            params.push(startDate);
        }
        if (endDate && typeof endDate === 'string' && endDate.trim() !== '') {
            where += ` AND created_at::date <= $${idx++}::date`;
            params.push(endDate);
        }
        if (priority && typeof priority === 'string' && priority.trim() !== '') {
            let priorityValue = priority;
            // Поддержка строковых значений
            if (priorityValue.toLowerCase() === 'high' || priorityValue === '3' || priorityValue === 'высокий')
                priorityValue = '3';
            else if (priorityValue.toLowerCase() === 'medium' || priorityValue === '2' || priorityValue === 'средний')
                priorityValue = '2';
            else if (priorityValue.toLowerCase() === 'low' || priorityValue === '1' || priorityValue === 'низкий')
                priorityValue = '1';
            where += ` AND priority = $${idx++}`;
            params.push(priorityValue);
        }
        const query = `
            SELECT
                CASE priority
                    WHEN 1 THEN 'Низкий'
                    WHEN 2 THEN 'Средний'
                    WHEN 3 THEN 'Высокий'
                    ELSE 'Не указан'
                END as priority,
                COUNT(*) as tasks_count
            FROM tasks
            ${where}
            GROUP BY priority
            ORDER BY priority;
        `;
        console.log('getTasksByPriority SQL:', query, params);
        const result = await pool.query(query, params);
        res.json(result.rows);
    }
    catch (error) {
        console.error('Error in getTasksByPriority:', error);
        res.status(500).json({ message: 'Failed to fetch tasks by priority', error: (error instanceof Error ? error.message : String(error)) });
    }
};
