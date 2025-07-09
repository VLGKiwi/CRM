import pool from '../config/database.js';
async function checkData() {
    try {
        console.log('Checking tasks table...');
        const result = await pool.query(`
			SELECT
				t.*,
				creator.first_name as creator_first_name,
				creator.last_name as creator_last_name
			FROM tasks t
			LEFT JOIN users creator ON t.created_by = creator.id
			WHERE t.deleted_at IS NULL
			LIMIT 5
		`);
        console.log('Found tasks:', result.rows);
        console.log('Total tasks found:', result.rowCount);
    }
    catch (error) {
        console.error('Error checking data:', error);
    }
    finally {
        await pool.end();
    }
}
checkData();
