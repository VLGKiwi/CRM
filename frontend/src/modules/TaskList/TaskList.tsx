'use client'
import { useTasks } from "@/shared/hooks/useTasks";
import { useEffect, useState } from "react";
import { useSession } from "next-auth/react";
import styles from './TaskList.module.scss';

interface NewTaskForm {
	title: string;
	description: string;
	due_date: string;
	priority: number;
	task_number: string;
	estimated_hours: number;
}

const initialFormState: NewTaskForm = {
	title: '',
	description: '',
	due_date: new Date().toISOString().split('T')[0],
	priority: 1,
	task_number: '',
	estimated_hours: 0
};

export const TaskList = () => {
	const { data: session } = useSession();
	const { tasks = [], loading, error, fetchTasks, createTask, deleteTask } = useTasks();
	const [showForm, setShowForm] = useState(false);
	const [formData, setFormData] = useState<NewTaskForm>(initialFormState);

	useEffect(() => {
		console.log('Session:', session);
		if (session?.accessToken) {
			console.log('Fetching tasks with token:', session.accessToken);
			fetchTasks();
		}
	}, [session?.accessToken, fetchTasks]);

	console.log('Current state:', { tasks, loading, error });

	const handleSubmit = async (e: React.FormEvent) => {
		e.preventDefault();
		try {
			await createTask({
				...formData,
				status: 'not_started',
				tags: [],
				actual_hours: null
			});
			setShowForm(false);
			setFormData(initialFormState);
		} catch (error) {
			console.error('Error creating task:', error);
		}
	};

	const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
		const { name, value } = e.target;
		setFormData(prev => ({
			...prev,
			[name]: name === 'priority' || name === 'estimated_hours' ? Number(value) : value
		}));
	};

	const handleDelete = async (taskId: number) => {
		if (window.confirm('Вы уверены, что хотите удалить эту задачу?')) {
			try {
				await deleteTask(taskId);
			} catch (error) {
				console.error('Error deleting task:', error);
			}
		}
	};

	if (loading) return <div>Загрузка...</div>;
	if (error) return <div>Ошибка: {error}</div>;
	if (tasks.length === 0 && !showForm) return <div>Задачи отсутствуют</div>;

	return (
		<div className={styles.taskList}>
			<button onClick={() => setShowForm(!showForm)}>
				{showForm ? 'Отменить' : 'Добавить новую задачу'}
			</button>

			{showForm && (
				<form onSubmit={handleSubmit} className={styles.taskForm}>
					<div>
						<label>
							Название задачи:
							<input
								type="text"
								name="title"
								value={formData.title}
								onChange={handleInputChange}
								required
							/>
						</label>
					</div>
					<div>
						<label>
							Описание:
							<textarea
								name="description"
								value={formData.description}
								onChange={handleInputChange}
								required
							/>
						</label>
					</div>
					<div>
						<label>
							Срок выполнения:
							<input
								type="date"
								name="due_date"
								value={formData.due_date}
								onChange={handleInputChange}
								required
							/>
						</label>
					</div>
					<div>
						<label>
							Приоритет:
							<select
								name="priority"
								value={formData.priority}
								onChange={handleInputChange}
								required
							>
								<option value="1">Низкий</option>
								<option value="2">Средний</option>
								<option value="3">Высокий</option>
							</select>
						</label>
					</div>
					<div>
						<label>
							Номер задачи:
							<input
								type="text"
								name="task_number"
								value={formData.task_number}
								onChange={handleInputChange}
								required
							/>
						</label>
					</div>
					<div>
						<label>
							Оценка времени (часы):
							<input
								type="number"
								name="estimated_hours"
								value={formData.estimated_hours}
								onChange={handleInputChange}
								min="0"
								required
							/>
						</label>
					</div>
					<button type="submit">Создать задачу</button>
				</form>
			)}

			<h2>Список задач:</h2>
			{tasks.map(task => (
				<div key={task.id} className={styles.taskItem}>
					<div className={styles.taskContent}>
						<div>ID: {task.id}</div>
						<div>Название: {task.title}</div>
						<div>Описание: {task.description}</div>
						<div>Статус: {task.status}</div>
						<div>Приоритет: {task.priority}</div>
						<div>Номер задачи: {task.task_number}</div>
					</div>
					<button
						className={styles.deleteButton}
						onClick={() => handleDelete(task.id)}
						title="Удалить задачу"
					>
						✕
					</button>
				</div>
			))}
		</div>
	);
}
