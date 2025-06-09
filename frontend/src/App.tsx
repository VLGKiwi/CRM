import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { Analytics } from './components/Analytics';
import Login from './components/auth/LoginForm';
// Import other components as needed

export const App: React.FC = () => {
	return (
		<Router>
			<Routes>
				<Route path="/login" element={<Login />} />
				<Route path="/" element={<Navigate to="/tasks" replace />} />
				<Route path="analytics" element={<Analytics />} />
			</Routes>
		</Router>
	);
};
