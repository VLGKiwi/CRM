import { useState, useCallback } from 'react';
import axios, { AxiosError } from 'axios';
import { useSession } from 'next-auth/react';

export interface User {
	id: string;
	email: string;
	firstName: string;
	lastName: string;
	role: 'admin' | 'manager' | 'developer';
	created_at: string;
	updated_at: string;
}

interface ErrorResponse {
	message: string;
}

interface UsersState {
	users: User[];
	loading: boolean;
	error: string | null;
}

interface UsersResponse {
	users: User[];
	pagination: {
		total: number;
		page: number;
		limit: number;
	};
}

export const useUsers = () => {
	const { data: session } = useSession();
	const [state, setState] = useState<UsersState>({
		users: [],
		loading: false,
		error: null,
	});

	const getAxiosConfig = useCallback(() => ({
		headers: {
			Authorization: `Bearer ${session?.accessToken}`,
			'Content-Type': 'application/json',
		},
	}), [session?.accessToken]);

	const handleError = useCallback((error: unknown) => {
		const axiosError = error as AxiosError<ErrorResponse>;
		if (axiosError.response?.status === 401) {
			return 'Ошибка авторизации. Пожалуйста, войдите снова.';
		}
		return axiosError.response?.data?.message || 'Произошла ошибка при выполнении запроса';
	}, []);

	const fetchUsers = useCallback(async () => {
		if (!session?.accessToken) {
			setState(prev => ({
				...prev,
				error: 'Необходима авторизация'
			}));
			return;
		}

		setState(prev => ({ ...prev, loading: true, error: null }));
		try {
			const response = await axios.get<UsersResponse>(
				'http://localhost:3001/api/users',
				getAxiosConfig()
			);
			setState(prev => ({
				...prev,
				users: response.data.users,
				loading: false,
			}));
		} catch (error) {
			setState(prev => ({
				...prev,
				loading: false,
				error: handleError(error),
			}));
		}
	}, [session?.accessToken, getAxiosConfig, handleError]);

	const deleteUser = useCallback(async (id: string) => {
		if (!session?.accessToken) {
			throw new Error('Необходима авторизация');
		}

		setState(prev => ({ ...prev, loading: true, error: null }));
		try {
			await axios.delete(
				`http://localhost:3001/api/users/${id}`,
				getAxiosConfig()
			);
			setState(prev => ({
				...prev,
				users: prev.users.filter(user => user.id !== id),
				loading: false,
			}));
		} catch (error) {
			const errorMessage = handleError(error);
			setState(prev => ({
				...prev,
				loading: false,
				error: errorMessage,
			}));
			throw new Error(errorMessage);
		}
	}, [session?.accessToken, getAxiosConfig, handleError]);

	return {
		users: state.users,
		loading: state.loading,
		error: state.error,
		fetchUsers,
		deleteUser,
	};
};
