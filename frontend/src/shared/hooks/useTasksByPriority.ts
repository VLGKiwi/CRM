import { useState, useEffect, useCallback } from 'react';
import { useSession } from 'next-auth/react';

export interface TaskPriorityAnalytics {
	priority: string;
	tasks_count: string;
}

export interface UseTasksByPriorityParams {
	startDate?: string;
	endDate?: string;
	priority?: string;
}

export const useTasksByPriority = (params?: UseTasksByPriorityParams) => {
	const { data: session, status } = useSession();
	const [data, setData] = useState<TaskPriorityAnalytics[]>([]);
	const [loading, setLoading] = useState(true);
	const [error, setError] = useState<string | null>(null);

	const fetchData = useCallback(async () => {
		if (status !== 'authenticated' || !session?.accessToken) {
			setError('Unauthorized');
			setLoading(false);
			return;
		}
		setLoading(true);
		setError(null);
		try {
			const url = new URL(`${process.env.NEXT_PUBLIC_API_URL}/api/analytics/tasks-by-priority`);
			if (params?.startDate) url.searchParams.append('startDate', params.startDate);
			if (params?.endDate) url.searchParams.append('endDate', params.endDate);
			if (params?.priority) url.searchParams.append('priority', params.priority);
			const response = await fetch(url.toString(), {
				headers: {
					Authorization: `Bearer ${session.accessToken}`,
				},
				cache: 'no-store',
			});
			if (!response.ok) {
				throw new Error('Failed to fetch tasks by priority');
			}
			const result = await response.json();
			setData(result);
		} catch (err) {
			setError(err instanceof Error ? err.message : 'Unknown error');
		} finally {
			setLoading(false);
		}
	}, [session?.accessToken, status, params?.startDate, params?.endDate, params?.priority]);

	useEffect(() => {
		fetchData();
	}, [fetchData]);

	return { data, loading, error, refetch: fetchData };
};
