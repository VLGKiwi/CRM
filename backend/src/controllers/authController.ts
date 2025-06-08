import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import pool from '../config/database.js';

export const login = async (req: Request, res: Response) => {
	const { email, password } = req.body;

	try {
		const result = await pool.query(
			`SELECT u.*, r.name as role_name
			 FROM users u
			 LEFT JOIN roles r ON u.role_id = r.id
			 WHERE u.email = $1 AND u.is_active = true`,
			[email]
		);

		const user = result.rows[0];

		if (!user) {
			return res.status(401).json({ message: 'Неверный email или пароль' });
		}

		const validPassword = await bcrypt.compare(password, user.password_hash);

		if (!validPassword) {
			return res.status(401).json({ message: 'Неверный email или пароль' });
		}

		// Обновляем время последнего входа
		await pool.query(
			'UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = $1',
			[user.id]
		);

		const token = jwt.sign(
			{
				id: user.id,
				email: user.email,
				role: user.role_name,
				firstName: user.first_name,
				lastName: user.last_name
			},
			process.env.JWT_SECRET || 'your-secret-key',
			{ expiresIn: '24h' }
		);

		res.json({
			token,
			user: {
				id: user.id,
				email: user.email,
				role: user.role_name,
				firstName: user.first_name,
				lastName: user.last_name,
				teamId: user.team_id
			}
		});
	} catch (error) {
		console.error('Login error:', error);
		res.status(500).json({ message: 'Ошибка сервера' });
	}
};

export const register = async (req: Request, res: Response) => {
	const { email, password, firstName, lastName, roleId } = req.body;

	try {
		const userExists = await pool.query(
			'SELECT * FROM users WHERE email = $1',
			[email]
		);

		if (userExists.rows.length > 0) {
			return res.status(400).json({ message: 'Пользователь уже существует' });
		}

		const hashedPassword = await bcrypt.hash(password, 10);

		const result = await pool.query(
			`INSERT INTO users
			 (email, password_hash, first_name, last_name, role_id, is_active)
			 VALUES ($1, $2, $3, $4, $5, true)
			 RETURNING *`,
			[email, hashedPassword, firstName, lastName, roleId]
		);

		const newUser = result.rows[0];

		const token = jwt.sign(
			{
				id: newUser.id,
				email: newUser.email,
				role: newUser.role_id,
				firstName: newUser.first_name,
				lastName: newUser.last_name
			},
			process.env.JWT_SECRET || 'your-secret-key',
			{ expiresIn: '24h' }
		);

		res.status(201).json({
			token,
			user: {
				id: newUser.id,
				email: newUser.email,
				role: newUser.role_id,
				firstName: newUser.first_name,
				lastName: newUser.last_name,
				teamId: newUser.team_id
			}
		});
	} catch (error) {
		console.error('Registration error:', error);
		res.status(500).json({ message: 'Ошибка сервера' });
	}
};
