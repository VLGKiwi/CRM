import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import pool from '../config/database.js';

const generateTokens = (user: any) => {
	const accessToken = jwt.sign(
		{
			id: user.id,
			email: user.email,
			role: user.role_name,
			firstName: user.first_name,
			lastName: user.last_name
		},
		process.env.JWT_SECRET!,
		{ expiresIn: '15m' }
	);

	const refreshToken = jwt.sign(
		{ id: user.id },
		process.env.JWT_REFRESH_SECRET!,
		{ expiresIn: '7d' }
	);

	return { accessToken, refreshToken };
};

const validatePassword = (password: string): boolean => {
	const minLength = 8;
	const hasUpperCase = /[A-Z]/.test(password);
	const hasLowerCase = /[a-z]/.test(password);
	const hasNumbers = /\d/.test(password);
	const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(password);

	return password.length >= minLength &&
		hasUpperCase &&
		hasLowerCase &&
		hasNumbers &&
		hasSpecialChar;
};

export const login = async (req: Request, res: Response) => {
	console.log('=== Login Request ===');
	console.log('Headers:', req.headers);
	console.log('Body:', req.body);

	const { email, password } = req.body;

	if (!email || !password) {
		console.log('Missing credentials:', { email: !!email, password: !!password });
		return res.status(400).json({ message: 'Email и пароль обязательны' });
	}

	try {
		console.log('Querying database for user:', email);
		const result = await pool.query(
			`SELECT u.*, r.name as role_name
			 FROM users u
			 LEFT JOIN roles r ON u.role_id = r.id
			 WHERE u.email = $1 AND u.is_active = true`,
			[email]
		);

		const user = result.rows[0];
		console.log('Database query result:', {
			found: !!user,
			userId: user?.id,
			userEmail: user?.email,
			userRole: user?.role_name
		});

		if (!user) {
			console.log('User not found');
			return res.status(401).json({ message: 'Неверный email или пароль' });
		}

		console.log('Validating password');
		const validPassword = await bcrypt.compare(password, user.password_hash);
		console.log('Password validation result:', validPassword);

		if (!validPassword) {
			console.log('Invalid password');
			return res.status(401).json({ message: 'Неверный email или пароль' });
		}

		console.log('Generating tokens');
		const { accessToken, refreshToken } = generateTokens(user);
		console.log('Tokens generated successfully');

		// Сохраняем refresh token в базе
		console.log('Updating refresh token in database');
		await pool.query(
			`UPDATE users
			 SET refresh_token = $1, last_login = CURRENT_TIMESTAMP
			 WHERE id = $2`,
			[refreshToken, user.id]
		);

		// Устанавливаем refresh token в httpOnly cookie
		console.log('Setting refresh token cookie');
		res.cookie('refreshToken', refreshToken, {
			httpOnly: true,
			secure: process.env.NODE_ENV === 'production',
			sameSite: 'strict',
			maxAge: 7 * 24 * 60 * 60 * 1000 // 7 days
		});

		const response = {
			token: accessToken,
			user: {
				id: user.id,
				email: user.email,
				role: user.role_name,
				firstName: user.first_name,
				lastName: user.last_name,
				teamId: user.team_id
			}
		};
		console.log('Sending response:', response);
		res.json(response);
	} catch (error) {
		console.error('Login error:', error);
		res.status(500).json({ message: 'Ошибка сервера' });
	}
};

export const register = async (req: Request, res: Response) => {
	const { email, password, firstName, lastName, roleId } = req.body;

	if (!validatePassword(password)) {
		return res.status(400).json({
			message: 'Пароль должен содержать минимум 8 символов, включая заглавные и строчные буквы, цифры и специальные символы'
		});
	}

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
		const { accessToken, refreshToken } = generateTokens(newUser);

		// Сохраняем refresh token
		await pool.query(
			'UPDATE users SET refresh_token = $1 WHERE id = $2',
			[refreshToken, newUser.id]
		);

		res.cookie('refreshToken', refreshToken, {
			httpOnly: true,
			secure: process.env.NODE_ENV === 'production',
			sameSite: 'strict',
			maxAge: 7 * 24 * 60 * 60 * 1000
		});

		res.status(201).json({
			token: accessToken,
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

export const refresh = async (req: Request, res: Response) => {
	const refreshToken = req.cookies.refreshToken;

	if (!refreshToken) {
		return res.status(401).json({ message: 'Отсутствует refresh token' });
	}

	try {
		const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET!) as any;

		const result = await pool.query(
			`SELECT u.*, r.name as role_name
			 FROM users u
			 LEFT JOIN roles r ON u.role_id = r.id
			 WHERE u.id = $1 AND u.refresh_token = $2`,
			[decoded.id, refreshToken]
		);

		const user = result.rows[0];

		if (!user) {
			return res.status(401).json({ message: 'Недействительный refresh token' });
		}

		const tokens = generateTokens(user);

		// Обновляем refresh token
		await pool.query(
			'UPDATE users SET refresh_token = $1 WHERE id = $2',
			[tokens.refreshToken, user.id]
		);

		res.cookie('refreshToken', tokens.refreshToken, {
			httpOnly: true,
			secure: process.env.NODE_ENV === 'production',
			sameSite: 'strict',
			maxAge: 7 * 24 * 60 * 60 * 1000
		});

		res.json({
			token: tokens.accessToken,
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
		return res.status(401).json({ message: 'Недействительный refresh token' });
	}
};

export const logout = async (req: Request, res: Response) => {
	const refreshToken = req.cookies.refreshToken;

	if (refreshToken) {
		try {
			const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET!) as any;
			await pool.query(
				'UPDATE users SET refresh_token = NULL WHERE id = $1',
				[decoded.id]
			);
		} catch (error) {
			// Игнорируем ошибку, так как токен может быть недействительным
		}
	}

	res.clearCookie('refreshToken');
	res.json({ message: 'Успешный выход' });
};
