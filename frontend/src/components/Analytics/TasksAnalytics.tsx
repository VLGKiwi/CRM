import React from 'react';
import {
	Table,
	TableBody,
	TableCell,
	TableContainer,
	TableHead,
	TableRow,
	Paper,
	Typography,
	Box,
	CircularProgress,
} from '@mui/material';

interface TaskAnalytics {
	status: string;
	priority: string;
	total_tasks: string;
	completed_tasks: string;
	completion_rate: string;
	avg_estimated_hours: string;
	avg_actual_hours: string;
}

interface TasksAnalyticsProps {
	startDate: Date | null;
	endDate: Date | null;
	data: TaskAnalytics[];
	isLoading: boolean;
	error: string | null;
}

export const TasksAnalytics: React.FC<TasksAnalyticsProps> = ({
	data: tasksAnalytics,
	isLoading,
	error
}) => {
	if (isLoading) {
		return (
			<Box display="flex" justifyContent="center" alignItems="center" minHeight="200px">
				<CircularProgress />
			</Box>
		);
	}

	if (error) {
		return (
			<Box p={2}>
				<Typography color="error">
					Ошибка при загрузке аналитики задач: {error}
				</Typography>
			</Box>
		);
	}

	const formatStatus = (status: string): string => {
		const statusMap: { [key: string]: string } = {
			'not_started': 'Не начата',
			'in_progress': 'В работе',
			'completed': 'Завершена',
			'on_hold': 'На паузе'
		};
		return statusMap[status] || status;
	};

	const formatPriority = (priority: string): string => {
		const priorityMap: { [key: string]: string } = {
			'low': 'Низкий',
			'medium': 'Средний',
			'high': 'Высокий',
			'unknown': 'Не указан'
		};
		return priorityMap[priority] || priority;
	};

	return (
		<Box p={2}>
			<Typography variant="h5" gutterBottom>
				Аналитика по задачам
			</Typography>

			<TableContainer component={Paper}>
				<Table>
					<TableHead>
						<TableRow>
							<TableCell>Статус</TableCell>
							<TableCell>Приоритет</TableCell>
							<TableCell align="right">Всего задач</TableCell>
							<TableCell align="right">Выполнено</TableCell>
							<TableCell align="right">% выполнения</TableCell>
							<TableCell align="right">Ср. оценка (ч)</TableCell>
							<TableCell align="right">Ср. факт (ч)</TableCell>
						</TableRow>
					</TableHead>
					<TableBody>
						{tasksAnalytics?.map((row: TaskAnalytics, index: number) => (
							<TableRow key={index}>
								<TableCell>{formatStatus(row.status)}</TableCell>
								<TableCell>{formatPriority(row.priority)}</TableCell>
								<TableCell align="right">{row.total_tasks}</TableCell>
								<TableCell align="right">{row.completed_tasks}</TableCell>
								<TableCell align="right">{row.completion_rate}</TableCell>
								<TableCell align="right">{row.avg_estimated_hours}</TableCell>
								<TableCell align="right">{row.avg_actual_hours}</TableCell>
							</TableRow>
						))}
					</TableBody>
				</Table>
			</TableContainer>
		</Box>
	);
};
