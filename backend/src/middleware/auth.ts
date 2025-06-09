import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

interface AuthRequest extends Request {
	user?: {
		id: string;
		email: string;
		role: string;
		firstName: string;
		lastName: string;
	};
}

export const authMiddleware = (req: AuthRequest, res: Response, next: NextFunction) => {
	try {
		console.log('AuthMiddleware: Incoming headers:', req.headers);
		const authHeader = req.header('Authorization');

		if (!authHeader) {
			console.warn('AuthMiddleware: No Authorization header');
			return res.status(401).json({ message: 'Требуется авторизация' });
		}

		const token = authHeader.replace('Bearer ', '');
		console.log('AuthMiddleware: Extracted token:', token);

		if (!token) {
			console.warn('AuthMiddleware: No token after Bearer');
			return res.status(401).json({ message: 'Требуется авторизация' });
		}

		const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key');
		req.user = decoded as AuthRequest['user'];
		next();
	} catch (error) {
		console.error('Auth middleware error:', error);
		res.status(401).json({ message: 'Недействительный токен' });
	}
};
