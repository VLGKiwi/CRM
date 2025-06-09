import pool from '../config/database.js';
async function checkTasks() {
    try {
        const query = `
            SELECT
                COUNT(*) as total_tasks,
                MIN(created_at) as earliest_task,
                MAX(created_at) as latest_task
            FROM tasks
            WHERE deleted_at IS NULL;
        `;
        const result = await pool.query(query);
        console.log('Tasks statistics:', result.rows[0]);
        const tasksQuery = `
            SELECT
                id,
                title,
                status,
                priority,
                created_at,
                developer_id
            FROM tasks
            WHERE deleted_at IS NULL
            ORDER BY created_at DESC
            LIMIT 5;
        `;
        const tasksResult = await pool.query(tasksQuery);
        console.log('\nLatest 5 tasks:', tasksResult.rows);
    }
    catch (error) {
        console.error('Error checking tasks:', error);
    }
    finally {
        await pool.end();
    }
}
checkTasks();
