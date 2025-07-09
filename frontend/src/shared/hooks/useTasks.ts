import { useState, useCallback } from 'react';
import axios, { AxiosError } from 'axios';
import { useSession } from 'next-auth/react';

// Типы для задач
export interface Task {
	id: number;
	title: string;
	description: string;
	due_date: string;
	priority: number;
	status: 'not_started' | 'in_progress' | 'completed';
	task_number: string;
	tags: string[];
	estimated_hours: number;
	actual_hours: number | null;
	created_at: string;
	updated_at: string;
}

// Тип для ответа с ошибкой
interface ErrorResponse {
	message: string;
}

// Состояние хука
interface TasksState {
	tasks: Task[];
	loading: boolean;
	error: string | null;
}

interface TasksResponse {
	tasks: Task[];
	pagination: {
		total: number;
		page: number;
		limit: number;
	};
}

// Хук для работы с задачами
export const useTasks = () => {
	const { data: session } = useSession();
	const [state, setState] = useState<TasksState>({
		tasks: [],
		loading: false,
		error: null,
	});

	// Конфигурация axios с токеном
	const getAxiosConfig = useCallback(() => ({
		headers: {
			Authorization: `Bearer ${session?.accessToken}`,
			'Content-Type': 'application/json',
		},
	}), [session?.accessToken]);

	// Обработка ошибок
	const handleError = useCallback((error: unknown) => {
		const axiosError = error as AxiosError<ErrorResponse>;
		if (axiosError.response?.status === 401) {
			return 'Ошибка авторизации. Пожалуйста, войдите снова.';
		}
		return axiosError.response?.data?.message || 'Произошла ошибка при выполнении запроса';
	}, []);

	// Получение списка задач
	const fetchTasks = useCallback(async () => {
		if (!session?.accessToken) {
			setState(prev => ({
				...prev,
				error: 'Необходима авторизация'
			}));
			return;
		}

		setState(prev => ({ ...prev, loading: true, error: null }));
		try {
			const response = await axios.get<TasksResponse>(
				'http://localhost:3001/api/tasks',
				getAxiosConfig()
			);
			setState(prev => ({
				...prev,
				tasks: response.data.tasks,
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

	// Создание новой задачи
	const createTask = useCallback(async (task: Omit<Task, 'id' | 'created_at' | 'updated_at'>) => {
		if (!session?.accessToken) {
			throw new Error('Необходима авторизация');
		}

		setState(prev => ({ ...prev, loading: true, error: null }));
		try {
			const response = await axios.post<Task>(
				'http://localhost:3001/api/tasks',
				task,
				getAxiosConfig()
			);
			setState(prev => ({
				...prev,
				tasks: [...prev.tasks, response.data],
				loading: false,
			}));
			return response.data;
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

	// Обновление задачи
	const updateTask = useCallback(async (id: number, updates: Partial<Task>) => {
		if (!session?.accessToken) {
			throw new Error('Необходима авторизация');
		}

		setState(prev => ({ ...prev, loading: true, error: null }));
		try {
			const response = await axios.put<Task>(
				`http://localhost:3001/api/tasks/${id}`,
				updates,
				getAxiosConfig()
			);
			setState(prev => ({
				...prev,
				tasks: prev.tasks.map(task => task.id === id ? response.data : task),
				loading: false,
			}));
			return response.data;
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

	// Удаление задачи
	const deleteTask = useCallback(async (id: number) => {
		if (!session?.accessToken) {
			throw new Error('Необходима авторизация');
		}

		setState(prev => ({ ...prev, loading: true, error: null }));
		try {
			await axios.delete(
				`http://localhost:3001/api/tasks/${id}`,
				getAxiosConfig()
			);
			setState(prev => ({
				...prev,
				tasks: prev.tasks.filter(task => task.id !== id),
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
		tasks: state.tasks,
		loading: state.loading,
		error: state.error,
		fetchTasks,
		createTask,
		updateTask,
		deleteTask,
	};
};
