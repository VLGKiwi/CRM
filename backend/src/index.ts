import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import authRoutes from './routes/auth.js';

dotenv.config();

const app = express();
const port = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Подключаем роуты авторизации
app.use('/api/auth', authRoutes);

// Start server
app.listen(port, () => {
	console.log(`Server is running on port ${port}`);
});
