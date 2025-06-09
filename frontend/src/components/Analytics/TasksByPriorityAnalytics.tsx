import React, { useState } from 'react';
import { useTasksByPriority } from '../../shared/hooks/useTasksByPriority';

const PRIORITY_OPTIONS = [
	{ value: '', label: 'Все' },
	{ value: '1', label: 'Низкий' },
	{ value: '2', label: 'Средний' },
	{ value: '3', label: 'Высокий' },
];

export const TasksByPriorityAnalytics: React.FC = () => {
	const today = new Date();
	const monthAgo = new Date();
	monthAgo.setMonth(today.getMonth() - 1);

	const [startDate, setStartDate] = useState(monthAgo.toISOString().split('T')[0]);
	const [endDate, setEndDate] = useState(today.toISOString().split('T')[0]);
	const [priority, setPriority] = useState('');
	const [query, setQuery] = useState({ startDate, endDate, priority });

	const { data, loading, error } = useTasksByPriority(query);

	const handleSubmit = (e: React.FormEvent) => {
		e.preventDefault();
		setQuery({ startDate, endDate, priority });
	};

	return (
		<div style={{ marginTop: 32 }}>
			<h3>Распределение задач по приоритету</h3>
			<form onSubmit={handleSubmit} style={{ display: 'flex', gap: 16, alignItems: 'center', marginBottom: 16 }}>
				<label>
					Начальная дата:
					<input type="date" value={startDate} onChange={e => setStartDate(e.target.value)} />
				</label>
				<label>
					Конечная дата:
					<input type="date" value={endDate} onChange={e => setEndDate(e.target.value)} />
				</label>
				<label>
					Приоритет:
					<select value={priority} onChange={e => setPriority(e.target.value)}>
						{PRIORITY_OPTIONS.map(opt => (
							<option key={opt.value} value={opt.value}>{opt.label}</option>
						))}
					</select>
				</label>
				<button type="submit">Показать</button>
			</form>
			{loading && <div>Загрузка аналитики по приоритету...</div>}
			{error && <div>Ошибка: {error}</div>}
			{!loading && !error && !data.length && <div>Нет данных по приоритетам задач.</div>}
			{!loading && !error && data.length > 0 && (
				<table style={{ borderCollapse: 'collapse', width: '100%' }}>
					<thead>
						<tr>
							<th style={{ border: '1px solid #ccc', padding: 8 }}>Приоритет</th>
							<th style={{ border: '1px solid #ccc', padding: 8 }}>Количество задач</th>
						</tr>
					</thead>
					<tbody>
						{data.map((row) => (
							<tr key={row.priority}>
								<td style={{ border: '1px solid #ccc', padding: 8 }}>{row.priority}</td>
								<td style={{ border: '1px solid #ccc', padding: 8 }}>{row.tasks_count}</td>
							</tr>
						))}
					</tbody>
				</table>
			)}
		</div>
	);
};
