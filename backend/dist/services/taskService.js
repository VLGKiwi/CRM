import pool from '../config/database.js';
// Получение всех задач с пагинацией и фильтрацией
export const getAllTasks = async (params) => {
    try {
        const { page = 1, limit = 10, status, priority, search, assignedTo, createdBy, startDate, endDate } = params;
        const offset = (page - 1) * limit;
        const conditions = ['deleted_at IS NULL'];
        const values = [];
        let paramCount = 1;
        if (status) {
            conditions.push(`status = $${paramCount}`);
            values.push(status);
            paramCount++;
        }
        if (priority) {
            conditions.push(`priority = $${paramCount}`);
            values.push(priority);
            paramCount++;
        }
        if (search) {
            conditions.push(`(title ILIKE $${paramCount} OR description ILIKE $${paramCount})`);
            values.push(`%${search}%`);
            paramCount++;
        }
        if (assignedTo) {
            conditions.push(`assigned_to = $${paramCount}`);
            values.push(assignedTo);
            paramCount++;
        }
        if (createdBy) {
            conditions.push(`created_by = $${paramCount}`);
            values.push(createdBy);
            paramCount++;
        }
        if (startDate) {
            conditions.push(`due_date >= $${paramCount}`);
            values.push(startDate);
            paramCount++;
        }
        if (endDate) {
            conditions.push(`due_date <= $${paramCount}`);
            values.push(endDate);
            paramCount++;
        }
        const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';
        // Получаем общее количество записей для пагинации
        const countQuery = `
			SELECT COUNT(*) as total
			FROM tasks
			${whereClause}
		`;
        const countResult = await pool.query(countQuery, values);
        const total = parseInt(countResult.rows[0].total);
        // Получаем задачи с информацией о создателе и исполнителе
        const query = `
			SELECT
				t.*,
				creator.first_name as creator_first_name,
				creator.last_name as creator_last_name,
				assignee.first_name as assignee_first_name,
				assignee.last_name as assignee_last_name
			FROM tasks t
			LEFT JOIN users creator ON t.created_by = creator.id
			LEFT JOIN users assignee ON t.assigned_to = assignee.id
			${whereClause}
			ORDER BY t.created_at DESC
			LIMIT $${paramCount} OFFSET $${paramCount + 1}
		`;
        values.push(limit, offset);
        const result = await pool.query(query, values);
        return {
            tasks: result.rows,
            pagination: {
                total,
                page,
                limit,
                totalPages: Math.ceil(total / limit)
            }
        };
    }
    catch (error) {
        console.error('Error fetching tasks:', error);
        throw error;
    }
};
// Получение задачи по ID с дополнительной информацией
export const getTaskById = async (taskId) => {
    try {
        const query = `
			SELECT
				t.*,
				creator.first_name as creator_first_name,
				creator.last_name as creator_last_name,
				assignee.first_name as assignee_first_name,
				assignee.last_name as assignee_last_name,
				(
					SELECT json_agg(
						json_build_object(
							'id', c.id,
							'content', c.content,
							'created_at', c.created_at,
							'user_id', c.user_id,
							'user_first_name', u.first_name,
							'user_last_name', u.last_name
						)
					)
					FROM comments c
					LEFT JOIN users u ON c.user_id = u.id
					WHERE c.task_id = t.id
					ORDER BY c.created_at DESC
				) as comments
			FROM tasks t
			LEFT JOIN users creator ON t.created_by = creator.id
			LEFT JOIN users assignee ON t.assigned_to = assignee.id
			WHERE t.id = $1 AND t.deleted_at IS NULL
		`;
        const result = await pool.query(query, [taskId]);
        return result.rows[0] || null;
    }
    catch (error) {
        console.error(`Error fetching task ${taskId}:`, error);
        throw error;
    }
};
// Создание новой задачи
export const createTask = async (taskData) => {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        // Генерируем номер задачи
        const numberResult = await client.query('SELECT COUNT(*) + 1 as next_number FROM tasks');
        const taskNumber = `TASK-${numberResult.rows[0].next_number.toString().padStart(4, '0')}`;
        const result = await client.query(`INSERT INTO tasks (
				title, description, due_date, priority, status,
				created_by, task_number, created_at, updated_at
			) VALUES (
				$1, $2, $3, $4, $5, $6, $7, NOW(), NOW()
			) RETURNING *`, [
            taskData.title,
            taskData.description,
            taskData.due_date,
            taskData.priority,
            taskData.status,
            taskData.created_by,
            taskNumber
        ]);
        await client.query('COMMIT');
        return result.rows[0];
    }
    catch (error) {
        await client.query('ROLLBACK');
        console.error('Error creating task:', error);
        throw error;
    }
    finally {
        client.release();
    }
};
// Обновление задачи
export const updateTask = async (taskId, taskData) => {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        // Проверяем существование задачи
        const existingTask = await client.query('SELECT id FROM tasks WHERE id = $1 AND deleted_at IS NULL FOR UPDATE', [taskId]);
        if (existingTask.rows.length === 0) {
            throw new Error('Task not found');
        }
        const updates = [];
        const values = [];
        let paramCount = 1;
        Object.entries(taskData).forEach(([key, value]) => {
            if (value !== undefined) {
                updates.push(`${key} = $${paramCount}`);
                values.push(value);
                paramCount++;
            }
        });
        if (updates.length === 0) {
            await client.query('ROLLBACK');
            return null;
        }
        values.push(taskId);
        const query = `
			UPDATE tasks
			SET ${updates.join(', ')}, updated_at = NOW()
			WHERE id = $${paramCount} AND deleted_at IS NULL
			RETURNING *
		`;
        const result = await client.query(query, values);
        // Если статус изменился, добавляем запись в историю
        if (taskData.status) {
            await client.query(`INSERT INTO task_history (
					task_id, field_name, old_value, new_value,
					changed_by, created_at
				) VALUES ($1, 'status',
					(SELECT status FROM tasks WHERE id = $1),
					$2, $3, NOW())`, [taskId, taskData.status, taskData.created_by]);
        }
        await client.query('COMMIT');
        return result.rows[0];
    }
    catch (error) {
        await client.query('ROLLBACK');
        console.error(`Error updating task ${taskId}:`, error);
        throw error;
    }
    finally {
        client.release();
    }
};
// Мягкое удаление задачи
export const deleteTask = async (taskId) => {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        // Проверяем существование задачи
        const existingTask = await client.query('SELECT id FROM tasks WHERE id = $1 AND deleted_at IS NULL FOR UPDATE', [taskId]);
        if (existingTask.rows.length === 0) {
            throw new Error('Task not found');
        }
        const result = await client.query('UPDATE tasks SET deleted_at = NOW() WHERE id = $1 RETURNING id', [taskId]);
        await client.query('COMMIT');
        return result.rows.length > 0;
    }
    catch (error) {
        await client.query('ROLLBACK');
        console.error(`Error deleting task ${taskId}:`, error);
        throw error;
    }
    finally {
        client.release();
    }
};
