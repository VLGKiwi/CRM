import pool from '../config/database.js';
async function checkTaskDetails() {
    try {
        const query = `
            SELECT
                t.*,
                d.first_name || ' ' || d.last_name as developer_name,
                pm.first_name || ' ' || pm.last_name as project_manager_name,
                tl.first_name || ' ' || tl.last_name as team_lead_name,
                i.first_name || ' ' || i.last_name as integrator_name,
                c.first_name || ' ' || c.last_name as creator_name
            FROM tasks t
            LEFT JOIN users d ON t.developer_id = d.id
            LEFT JOIN users pm ON t.project_manager_id = pm.id
            LEFT JOIN users tl ON t.team_lead_id = tl.id
            LEFT JOIN users i ON t.integrator_id = i.id
            LEFT JOIN users c ON t.created_by = c.id
            WHERE t.deleted_at IS NULL
            ORDER BY t.created_at DESC;
        `;
        const result = await pool.query(query);
        console.log('Task details:', JSON.stringify(result.rows, null, 2));
    }
    catch (error) {
        console.error('Error checking task details:', error);
    }
    finally {
        await pool.end();
    }
}
checkTaskDetails();
