import React from 'react';
import { Outlet } from 'react-router-dom';

export const Layout: React.FC = () => {
	return (
		<div className="app-layout">
			<header className="app-header">
				<h1>CRM System</h1>
			</header>
			<main className="app-main">
				<Outlet />
			</main>
		</div>
	);
};
