import { useState, useEffect, useCallback } from 'react';
import { format } from 'date-fns';

interface TaskAnalytics {
	status: string;
	priority: string;
	total_tasks: number;
	completed_tasks: number;
	completion_rate: string;
	avg_estimated_hours: number;
	avg_actual_hours?: number;
}

interface UserWorkload {
	name: string;
	role: string;
	total_tasks: number;
	completed_tasks: number;
	completion_rate: string;
	total_estimated_hours: number;
	total_actual_hours: number;
	avg_efficiency: string;
}

interface UseAnalyticsProps {
	startDate?: Date | null;
	endDate?: Date | null;
}

const BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001';

export const useAnalytics = (props?: UseAnalyticsProps) => {
	const [tasksAnalytics, setTasksAnalytics] = useState<TaskAnalytics[]>([]);
	const [usersWorkload, setUsersWorkload] = useState<UserWorkload[]>([]);
	const [isLoading, setIsLoading] = useState(false);
	const [error, setError] = useState<string | null>(null);

	const { startDate, endDate } = props || {};

	const formatDateParam = (date: Date | null | undefined) => {
		if (!date) return undefined;
		return format(date, 'yyyy-MM-dd');
	};

	const parseResponse = async (response: Response) => {
		const text = await response.text();
		try {
			return JSON.parse(text);
		} catch (e) {
			console.error('Failed to parse response:', text);
			throw new Error('Invalid response format from server');
		}
	};

	const fetchTasksAnalytics = useCallback(async () => {
		try {
			const params = new URLSearchParams();
			if (startDate) params.append('startDate', formatDateParam(startDate)!);
			if (endDate) params.append('endDate', formatDateParam(endDate)!);

			const response = await fetch(`${BASE_URL}/api/analytics/tasks?${params.toString()}`, {
				headers: {
					'Authorization': `Bearer ${localStorage.getItem('token')}`
				},
				credentials: 'include'
			});

			if (!response.ok) {
				const errorText = await response.text();
				console.error('Server error response:', errorText);
				throw new Error(`HTTP error! status: ${response.status}`);
			}

			const data = await parseResponse(response);
			if (Array.isArray(data)) {
				setTasksAnalytics(data);
			} else {
				console.error('Unexpected data format:', data);
				throw new Error('Unexpected data format from server');
			}
		} catch (err) {
			console.error('Error in fetchTasksAnalytics:', err);
			setError(err instanceof Error ? err.message : 'Failed to fetch tasks analytics');
			setTasksAnalytics([]);
		}
	}, [startDate, endDate]);

	const fetchUsersWorkload = useCallback(async () => {
		try {
			const params = new URLSearchParams();
			if (startDate) params.append('startDate', formatDateParam(startDate)!);
			if (endDate) params.append('endDate', formatDateParam(endDate)!);

			const response = await fetch(`${BASE_URL}/api/analytics/users-workload?${params.toString()}`, {
				headers: {
					'Authorization': `Bearer ${localStorage.getItem('token')}`
				},
				credentials: 'include'
			});

			if (!response.ok) {
				const errorText = await response.text();
				console.error('Server error response:', errorText);
				throw new Error(`HTTP error! status: ${response.status}`);
			}

			const data = await parseResponse(response);
			if (Array.isArray(data)) {
				setUsersWorkload(data);
			} else {
				console.error('Unexpected data format:', data);
				throw new Error('Unexpected data format from server');
			}
		} catch (err) {
			console.error('Error in fetchUsersWorkload:', err);
			setError(err instanceof Error ? err.message : 'Failed to fetch users workload');
			setUsersWorkload([]);
		}
	}, [startDate, endDate]);

	useEffect(() => {
		const fetchData = async () => {
			setIsLoading(true);
			setError(null);
			try {
				await Promise.all([
					fetchTasksAnalytics(),
					fetchUsersWorkload()
				]);
			} catch (err) {
				console.error('Error in fetchData:', err);
			} finally {
				setIsLoading(false);
			}
		};

		fetchData();
	}, [fetchTasksAnalytics, fetchUsersWorkload]);

	return {
		tasksAnalytics,
		usersWorkload,
		isLoading,
		error,
		fetchTasksAnalytics,
		fetchUsersWorkload,
		refetch: useCallback(async () => {
			await Promise.all([
				fetchTasksAnalytics(),
				fetchUsersWorkload()
			]);
		}, [fetchTasksAnalytics, fetchUsersWorkload])
	};
};
