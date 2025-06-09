import { Router } from 'express';
import * as taskController from '../controllers/taskController.js';
import { authMiddleware } from '../middleware/auth.js';
const router = Router();
// Защищаем все маршруты
router.use(authMiddleware);
// Получить все задачи
router.get('/', taskController.getTasks);
// Получить задачу по ID
router.get('/:id', taskController.getTask);
// Создать новую задачу
router.post('/', taskController.createTask);
// Обновить задачу
router.put('/:id', taskController.updateTask);
// Удалить задачу
router.delete('/:id', taskController.deleteTask);
export default router;
