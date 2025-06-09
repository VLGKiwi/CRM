import { Router } from 'express';
import { getTasksAnalytics, getUsersWorkload } from '../controllers/analyticsController.js';
import { authMiddleware } from '../middleware/auth.js';

const router = Router();

// Protect all analytics routes
router.use(authMiddleware);

// Get tasks analytics
router.get('/tasks', getTasksAnalytics);

// Get users workload
router.get('/users-workload', getUsersWorkload);

export default router;
