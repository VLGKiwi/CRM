import { useState, useEffect, useCallback } from 'react';
import { format } from 'date-fns';
import { useSession } from 'next-auth/react';

interface TaskAnalytics {
	status: string;
	priority: string;
	total_tasks: number;
	completed_tasks: number;
	completion_rate: string;
	avg_estimated_hours: number;
	avg_actual_hours: number;
}

interface UserWorkload {
	name: string;
	role: string;
	roles_in_tasks: string;
	total_tasks: number;
	completed_tasks: number;
	completion_rate: string;
	total_estimated_hours: number;
	total_actual_hours: number;
	efficiency_ratio: string;
}

interface UseAnalyticsProps {
	startDate?: Date;
	endDate?: Date;
}

const BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001';

export const useAnalytics = (props?: UseAnalyticsProps) => {
	const { data: session, status } = useSession();
	const [tasksAnalytics, setTasksAnalytics] = useState<TaskAnalytics[]>([]);
	const [usersWorkload, setUsersWorkload] = useState<UserWorkload[]>([]);
	const [loading, setLoading] = useState(true);
	const [error, setError] = useState<string | null>(null);

	const formatDate = (date: Date) => {
		return format(date, 'yyyy-MM-dd');
	};

	const fetchTasksAnalytics = useCallback(async () => {
		if (status !== 'authenticated' || !session?.accessToken) {
			setError('Unauthorized');
			return;
		}

		try {
			const params = new URLSearchParams();
			if (props?.startDate) {
				const formattedStartDate = formatDate(props.startDate);
				if (!formattedStartDate) {
					setError('Invalid start date format');
					return;
				}
				params.append('startDate', formattedStartDate);
			}
			if (props?.endDate) {
				const formattedEndDate = formatDate(props.endDate);
				if (!formattedEndDate) {
					setError('Invalid end date format');
					return;
				}
				params.append('endDate', formattedEndDate);
			}

			const response = await fetch(`${BASE_URL}/api/analytics/tasks?${params.toString()}`, {
				headers: {
					'Authorization': `Bearer ${session.accessToken}`
				},
				credentials: 'include'
			});

			if (!response.ok) {
				const errorData = await response.json().catch(() => ({ message: 'Failed to fetch tasks analytics' }));
				throw new Error(errorData.message || `HTTP error! status: ${response.status}`);
			}

			const data = await response.json();
			console.log('Tasks analytics data:', data);
			setTasksAnalytics(data);
		} catch (err) {
			console.error('Error fetching tasks analytics:', err);
			setError(err instanceof Error ? err.message : 'Failed to fetch tasks analytics');
		}
	}, [session?.accessToken, status, props?.startDate, props?.endDate]);

	const fetchUsersWorkload = useCallback(async () => {
		if (status !== 'authenticated' || !session?.accessToken) {
			setError('Unauthorized');
			return;
		}

		try {
			const params = new URLSearchParams();
			if (props?.startDate) {
				params.append('startDate', formatDate(props.startDate));
			}
			if (props?.endDate) {
				params.append('endDate', formatDate(props.endDate));
			}

			const response = await fetch(`${BASE_URL}/api/analytics/users-workload?${params.toString()}`, {
				headers: {
					'Authorization': `Bearer ${session.accessToken}`
				},
				credentials: 'include'
			});

			if (!response.ok) {
				const errorData = await response.json().catch(() => ({ message: 'Failed to fetch users workload' }));
				throw new Error(errorData.message || `HTTP error! status: ${response.status}`);
			}

			const data = await response.json();
			console.log('Users workload data:', data);
			setUsersWorkload(data);
		} catch (err) {
			console.error('Error fetching users workload:', err);
			setError(err instanceof Error ? err.message : 'Failed to fetch users workload');
		}
	}, [session?.accessToken, status, props?.startDate, props?.endDate]);

	useEffect(() => {
		const fetchData = async () => {
			if (status !== 'authenticated' || !session?.accessToken) {
				setLoading(false);
				return;
			}

			setLoading(true);
			setError(null);
			try {
				await Promise.all([fetchTasksAnalytics(), fetchUsersWorkload()]);
			} catch (err) {
				console.error('Error in fetchData:', err);
				setError(err instanceof Error ? err.message : 'Failed to fetch analytics data');
			} finally {
				setLoading(false);
			}
		};

		fetchData();
	}, [session?.accessToken, status, fetchTasksAnalytics, fetchUsersWorkload]);

	return {
		tasksAnalytics,
		usersWorkload,
		loading,
		error,
		fetchTasksAnalytics,
		fetchUsersWorkload,
		refetch: () => {
			setLoading(true);
			setError(null);
			return Promise.all([fetchTasksAnalytics(), fetchUsersWorkload()])
				.finally(() => setLoading(false));
		}
	};
};
