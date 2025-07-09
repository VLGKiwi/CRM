import { Router } from 'express';
import { getTasksAnalytics, getUsersWorkload, getTasksByPriority } from '../controllers/analyticsController.js';
import { authMiddleware } from '../middleware/auth.js';
const router = Router();
// Protect all analytics routes
router.use(authMiddleware);
// Get tasks analytics
router.get('/tasks', getTasksAnalytics);
// Get users workload
router.get('/users-workload', getUsersWorkload);
// Get tasks by priority
router.get('/tasks-by-priority', getTasksByPriority);
export default router;
