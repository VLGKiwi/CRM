import { Request, Response } from 'express';
import * as taskService from '../services/taskService.js';

// Получить все задачи
export const getTasks = async (req: Request, res: Response) => {
	try {
		// Получаем параметры из query
		const {
			page = 1,
			limit = 10,
			status,
			priority,
			search,
			assignedTo,
			startDate,
			endDate
		} = req.query;

		const tasks = await taskService.getAllTasks({
			page: Number(page),
			limit: Number(limit),
			status: status as string,
			priority: priority ? Number(priority) : undefined,
			search: search as string,
			assignedTo: assignedTo as string,
			startDate: startDate ? new Date(startDate as string) : undefined,
			endDate: endDate ? new Date(endDate as string) : undefined
		});

		res.json(tasks);
	} catch (error) {
		console.error('Error getting tasks:', error);
		res.status(500).json({ message: 'Ошибка при получении задач' });
	}
};

// Получить задачу по ID
export const getTask = async (req: Request, res: Response) => {
	try {
		const task = await taskService.getTaskById(req.params.id);
		if (!task) {
			return res.status(404).json({ message: 'Task not found' });
		}
		res.json(task);
	} catch (error) {
		console.error('Error in getTask:', error);
		res.status(500).json({ message: 'Internal server error' });
	}
};

// Создать задачу
export const createTask = async (req: Request, res: Response) => {
	try {
		const userId = (req as any).user?.id; // ID из токена
		const taskData = {
			...req.body,
			created_by: userId
		};
		const task = await taskService.createTask(taskData);
		res.status(201).json(task);
	} catch (error) {
		console.error('Error in createTask:', error);
		res.status(500).json({ message: 'Internal server error' });
	}
};

// Обновить задачу
export const updateTask = async (req: Request, res: Response) => {
	try {
		const task = await taskService.updateTask(req.params.id, req.body);
		if (!task) {
			return res.status(404).json({ message: 'Task not found' });
		}
		res.json(task);
	} catch (error) {
		console.error('Error in updateTask:', error);
		res.status(500).json({ message: 'Internal server error' });
	}
};

// Удалить задачу
export const deleteTask = async (req: Request, res: Response) => {
	try {
		const success = await taskService.deleteTask(req.params.id);
		if (!success) {
			return res.status(404).json({ message: 'Task not found' });
		}
		res.status(204).send();
	} catch (error) {
		console.error('Error in deleteTask:', error);
		res.status(500).json({ message: 'Internal server error' });
	}
};
