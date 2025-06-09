import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { Analytics } from './components/Analytics';
import { PrivateRoute } from './components/auth/PrivateRoute';
import { Layout } from './components/Layout';
import { Login } from './components/auth/Login';
import { Tasks } from './components/Task';
// Import other components as needed

export const App: React.FC = () => {
	return (
		<Router>
			<Routes>
				<Route path="/login" element={<Login />} />
				<Route path="/" element={<PrivateRoute><Layout /></PrivateRoute>}>
					<Route index element={<Navigate to="/tasks" replace />} />
					<Route path="tasks" element={<Tasks />} />
					<Route path="analytics" element={<Analytics />} />
					{/* Add other routes as needed */}
				</Route>
			</Routes>
		</Router>
	);
};
