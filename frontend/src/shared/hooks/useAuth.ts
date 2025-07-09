import { useState } from 'react';
import axios from 'axios';

interface AuthResponse {
	token: string;
	user: {
		id: string;
		email: string;
	};
}

export const useAuth = () => {
	const [token, setToken] = useState<string | null>(localStorage.getItem('token'));

	const login = async (email: string, password: string) => {
		try {
			const response = await axios.post<AuthResponse>('http://localhost:3001/api/auth/login', {
				email,
				password
			});

			const { token } = response.data;
			localStorage.setItem('token', token);
			setToken(token);

			// Устанавливаем токен для всех последующих запросов
			axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;

			return response.data;
		} catch (error) {
			localStorage.removeItem('token');
			setToken(null);
			throw error;
		}
	};

	const logout = () => {
		localStorage.removeItem('token');
		setToken(null);
		delete axios.defaults.headers.common['Authorization'];
	};

	const isAuthenticated = () => {
		return !!token;
	};

	return {
		token,
		login,
		logout,
		isAuthenticated
	};
};
