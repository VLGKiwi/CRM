'use client'
import { useEffect, useState } from 'react';
import { useAnalytics } from '@/shared/hooks/useAnalytics';
import styles from './Analytics.module.scss';

export const Analytics = () => {
	const [dateRange, setDateRange] = useState({
		startDate: new Date(new Date().setMonth(new Date().getMonth() - 1)),
		endDate: new Date()
	});

	const { tasksAnalytics, usersWorkload, loading, error, refetch } = useAnalytics({
		startDate: dateRange.startDate,
		endDate: dateRange.endDate
	});

	const handleDateChange = (e: React.ChangeEvent<HTMLInputElement>) => {
		const { name, value } = e.target;
		setDateRange(prev => ({
			...prev,
			[name]: new Date(value)
		}));
	};

	if (loading) return <div>Загрузка...</div>;
	if (error) return <div>Ошибка: {error}</div>;

	return (
		<div className={styles.analytics}>
			<div className={styles.dateControls}>
				<div className={styles.dateField}>
					<label>Начальная дата:</label>
					<input
						type="date"
						name="startDate"
						value={dateRange.startDate.toISOString().split('T')[0]}
						onChange={handleDateChange}
					/>
				</div>
				<div className={styles.dateField}>
					<label>Конечная дата:</label>
					<input
						type="date"
						name="endDate"
						value={dateRange.endDate.toISOString().split('T')[0]}
						onChange={handleDateChange}
					/>
				</div>
			</div>

			<div className={styles.section}>
				<h2>Анализ задач по статусу и приоритету</h2>
				<div className={styles.tasksGrid}>
					{tasksAnalytics.map((analytics, index) => (
						<div key={index} className={styles.analyticsCard}>
							<div className={styles.cardHeader}>
								<div className={styles.priority}>{analytics.priority}</div>
								<div className={styles.status}>{analytics.status}</div>
							</div>
							<div className={styles.cardBody}>
								<div>Всего задач: {analytics.total_tasks}</div>
								<div>Выполнено: {analytics.completed_tasks}</div>
								<div>Процент выполнения: {analytics.completion_rate}</div>
								<div>Среднее оценочное время: {analytics.avg_estimated_hours}ч</div>
								{analytics.avg_actual_hours && (
									<div>Среднее фактическое время: {analytics.avg_actual_hours}ч</div>
								)}
							</div>
						</div>
					))}
				</div>
			</div>

			<div className={styles.section}>
				<h2>Статистика по сотрудникам</h2>
				<div className={styles.usersTable}>
					<table>
						<thead>
							<tr>
								<th>Сотрудник</th>
								<th>Роль</th>
								<th>Всего задач</th>
								<th>Выполнено</th>
								<th>% выполнения</th>
								<th>План. время</th>
								<th>Факт. время</th>
								<th>Эффективность</th>
							</tr>
						</thead>
						<tbody>
							{usersWorkload.map((user, index) => (
								<tr key={index}>
									<td>{user.name}</td>
									<td>{user.role}</td>
									<td>{user.total_tasks}</td>
									<td>{user.completed_tasks}</td>
									<td>{user.completion_rate}</td>
									<td>{user.total_estimated_hours}ч</td>
									<td>{user.total_actual_hours}ч</td>
									<td>{user.efficiency_ratio}</td>
								</tr>
							))}
						</tbody>
					</table>
				</div>
			</div>
		</div>
	);
};
