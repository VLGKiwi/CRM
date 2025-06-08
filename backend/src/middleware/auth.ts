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
		const authHeader = req.header('Authorization');

		if (!authHeader) {
			return res.status(401).json({ message: 'Требуется авторизация' });
		}

		const token = authHeader.replace('Bearer ', '');

		if (!token) {
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
