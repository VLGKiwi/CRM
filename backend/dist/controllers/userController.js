import pool from '../config/database.js';
export const getUsers = async (req, res) => {
    try {
        const result = await pool.query(`SELECT u.id, u.email, u.first_name, u.last_name, r.name as role
			 FROM users u
			 LEFT JOIN roles r ON u.role_id = r.id
			 WHERE u.is_active = true
			 ORDER BY u.created_at DESC`);
        const users = result.rows.map(user => ({
            id: user.id,
            email: user.email,
            firstName: user.first_name,
            lastName: user.last_name,
            role: user.role,
            created_at: user.created_at,
            updated_at: user.updated_at
        }));
        res.json({
            users,
            pagination: {
                total: users.length,
                page: 1,
                limit: users.length
            }
        });
    }
    catch (error) {
        console.error('Error in getUsers:', error);
        res.status(500).json({ message: 'Ошибка сервера' });
    }
};
export const deleteUser = async (req, res) => {
    const { id } = req.params;
    try {
        // Проверяем, не пытается ли пользователь удалить сам себя
        const currentUserId = req.user?.id;
        if (currentUserId === id) {
            return res.status(400).json({ message: 'Нельзя удалить свой собственный аккаунт' });
        }
        // Soft delete - просто помечаем пользователя как неактивного
        const result = await pool.query(`UPDATE users
			 SET is_active = false, updated_at = CURRENT_TIMESTAMP
			 WHERE id = $1 AND is_active = true
			 RETURNING id`, [id]);
        if (result.rowCount === 0) {
            return res.status(404).json({ message: 'Пользователь не найден' });
        }
        res.json({ message: 'Пользователь успешно удален' });
    }
    catch (error) {
        console.error('Error in deleteUser:', error);
        res.status(500).json({ message: 'Ошибка сервера' });
    }
};
