'use client'
import { useTasks } from "@/shared/hooks/useTasks";
import { useEffect } from "react";
import { useSession } from "next-auth/react";
import styles from './TaskList.module.scss';
export const TaskList = () => {
	const { data: session } = useSession();
	const { tasks = [], loading, error, fetchTasks } = useTasks();

	useEffect(() => {
		console.log('Session:', session);
		if (session?.accessToken) {
			console.log('Fetching tasks with token:', session.accessToken);
			fetchTasks();
		}
	}, [session?.accessToken, fetchTasks]);

	console.log('Current state:', { tasks, loading, error });

	if (loading) return <div>Загрузка...</div>;
	if (error) return <div>Ошибка: {error}</div>;
	if (tasks.length === 0) return <div>Задачи отсутствуют</div>;

	return (
		<div className={styles.taskList}>
			<h2>Список задач:</h2>
			{tasks.map(task => (
				<div key={task.id} style={{ margin: '10px 0', padding: '5px', borderBottom: '1px solid #ccc' }}>
					<div>ID: {task.id}</div>
					<div>Название: {task.title}</div>
					<div>Описание: {task.description}</div>
					<div>Статус: {task.status}</div>
					<div>Приоритет: {task.priority}</div>
					<div>Номер задачи: {task.task_number}</div>
				</div>
			))}
		</div>
	);
}
