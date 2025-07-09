import { Router } from 'express';
import * as userController from '../controllers/userController.js';
import { authMiddleware } from '../middleware/auth.js';
const router = Router();
// Защищаем все маршруты
router.use(authMiddleware);
// Получение списка пользователей
router.get('/', userController.getUsers);
// Удаление пользователя
router.delete('/:id', userController.deleteUser);
export default router;
