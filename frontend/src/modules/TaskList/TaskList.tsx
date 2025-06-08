'use client'
import { Task } from "@/components/Task/Task"
import { useTasks } from "@/shared/hooks/useTasks";
import { useCallback, useEffect, useMemo, useState } from "react";
import styles from './TaskList.module.css';
import { useSession } from "next-auth/react";

export const TaskList = () => {
	const { data: session } = useSession();
	const {
		tasks,
		loading,
		error,
		fetchTasks,
		createTask,
		updateTask,
		deleteTask
	} = useTasks();

	const [filters, setFilters] = useState({
		status: '',
		priority: '',
		search: ''
	});

	useEffect(() => {
		if (session?.accessToken) {
			fetchTasks();
		}
	}, [session?.accessToken, fetchTasks]);

	// Фильтрация задач
	const filteredTasks = useMemo(() => {
		return tasks.filter(task => {
			const matchesStatus = !filters.status || task.status === filters.status;
			const matchesPriority = !filters.priority || task.priority.toString() === filters.priority;
			const matchesSearch = !filters.search ||
				task.title.toLowerCase().includes(filters.search.toLowerCase()) ||
				task.description.toLowerCase().includes(filters.search.toLowerCase());

			return matchesStatus && matchesPriority && matchesSearch;
		});
	}, [tasks, filters]);

	// Создание задачи
	const handleCreateTask = useCallback(async () => {
		try {
			const newTask = await createTask({
				title: "Новая задача",
				description: "Описание задачи",
				due_date: new Date().toISOString(),
				priority: 1,
				status: "not_started",
				task_number: "",
				tags: [],
				estimated_hours: 0,
				actual_hours: null
			});
			console.log('Created task:', newTask);
		} catch (error) {
			console.error('Error creating task:', error);
		}
	}, [createTask]);

	// Обновление задачи
	const handleUpdateTask = useCallback(async (taskId: number, updates: any) => {
		try {
			const updated = await updateTask(taskId, updates);
			console.log('Updated task:', updated);
		} catch (error) {
			console.error('Error updating task:', error);
		}
	}, [updateTask]);

	// Удаление задачи
	const handleDeleteTask = useCallback(async (taskId: number) => {
		try {
			await deleteTask(taskId);
			console.log('Task deleted:', taskId);
		} catch (error) {
			console.error('Error deleting task:', error);
		}
	}, [deleteTask]);

	const getStatusColor = useCallback((status: string) => {
		switch (status) {
			case 'not_started':
				return styles.statusNew;
			case 'in_progress':
				return styles.statusInProgress;
			case 'completed':
				return styles.statusCompleted;
			default:
				return '';
		}
	}, []);

	const getPriorityLabel = useCallback((priority: number) => {
		switch (priority) {
			case 1:
				return 'Низкий';
			case 2:
				return 'Средний';
			case 3:
				return 'Высокий';
			default:
				return 'Не указан';
		}
	}, []);

	if (loading) return (
		<div className={styles.loading}>
			<div className={styles.spinner}></div>
			<p>Загрузка задач...</p>
		</div>
	);

	if (error) return (
		<div className={styles.error}>
			<p>Ошибка: {error}</p>
			<button onClick={fetchTasks}>Попробовать снова</button>
		</div>
	);

	return (
		<div className={styles.container}>
			<div className={styles.header}>
				<h1>Задачи</h1>
				<button className={styles.createButton} onClick={handleCreateTask}>
					Создать задачу
				</button>
			</div>

			<div className={styles.filters}>
				<input
					type="text"
					placeholder="Поиск по названию..."
					value={filters.search}
					onChange={(e) => setFilters(prev => ({ ...prev, search: e.target.value }))}
					className={styles.searchInput}
				/>
				<select
					value={filters.status}
					onChange={(e) => setFilters(prev => ({ ...prev, status: e.target.value }))}
					className={styles.select}
				>
					<option value="">Все статусы</option>
					<option value="not_started">Не начата</option>
					<option value="in_progress">В работе</option>
					<option value="completed">Завершена</option>
				</select>
				<select
					value={filters.priority}
					onChange={(e) => setFilters(prev => ({ ...prev, priority: e.target.value }))}
					className={styles.select}
				>
					<option value="">Все приоритеты</option>
					<option value="1">Низкий</option>
					<option value="2">Средний</option>
					<option value="3">Высокий</option>
				</select>
			</div>

			<div className={styles.taskList}>
				{filteredTasks.length === 0 ? (
					<div className={styles.noTasks}>
						<p>Задачи не найдены</p>
					</div>
				) : (
					filteredTasks.map(task => (
						<div key={task.id} className={styles.taskCard}>
							<div className={styles.taskHeader}>
								<h3>{task.title}</h3>
								<span className={`${styles.status} ${getStatusColor(task.status)}`}>
									{task.status === 'not_started' ? 'Не начата' :
										task.status === 'in_progress' ? 'В работе' : 'Завершена'}
								</span>
							</div>
							<p className={styles.taskNumber}>#{task.task_number}</p>
							<p className={styles.description}>{task.description}</p>
							<div className={styles.taskInfo}>
								<span className={styles.priority}>
									Приоритет: {getPriorityLabel(task.priority)}
								</span>
								<span className={styles.dueDate}>
									Срок: {new Date(task.due_date).toLocaleDateString()}
								</span>
							</div>
							<div className={styles.actions}>
								<button
									onClick={() => handleUpdateTask(task.id, { status: 'in_progress' })}
									className={styles.actionButton}
								>
									Взять в работу
								</button>
								<button
									onClick={() => handleDeleteTask(task.id)}
									className={`${styles.actionButton} ${styles.deleteButton}`}
								>
									Удалить
								</button>
							</div>
						</div>
					))
				)}
			</div>
		</div>
	);
}
