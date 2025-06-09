import React, { useState, useEffect } from 'react';
import {
	Box,
	Container,
	Tab,
	Tabs,
	Paper,
	Typography,
} from '@mui/material';
import { TasksAnalytics } from './TasksAnalytics';
import { UsersWorkload } from './UsersWorkload';
import { LocalizationProvider } from '@mui/x-date-pickers/LocalizationProvider';
import { AdapterDateFns } from '@mui/x-date-pickers/AdapterDateFns';
import { DatePicker } from '@mui/x-date-pickers/DatePicker';
import { ru } from 'date-fns/locale';
import { useAnalytics } from '../../shared/hooks/useAnalytics';

interface TabPanelProps {
	children?: React.ReactNode;
	index: number;
	value: number;
}

function TabPanel(props: TabPanelProps) {
	const { children, value, index, ...other } = props;

	return (
		<div
			role="tabpanel"
			hidden={value !== index}
			id={`analytics-tabpanel-${index}`}
			aria-labelledby={`analytics-tab-${index}`}
			{...other}
		>
			{value === index && <Box>{children}</Box>}
		</div>
	);
}

export const Analytics: React.FC = () => {
	const [tabValue, setTabValue] = useState(0);
	const [startDate, setStartDate] = useState<Date | null>(
		new Date(new Date().setMonth(new Date().getMonth() - 1))
	);
	const [endDate, setEndDate] = useState<Date | null>(new Date());

	const {
		tasksAnalytics,
		usersWorkload,
		isLoading,
		error,
		fetchTasksAnalytics,
		fetchUsersWorkload
	} = useAnalytics({ startDate, endDate });

	useEffect(() => {
		const fetchData = async () => {
			try {
				await Promise.all([
					fetchTasksAnalytics(),
					fetchUsersWorkload()
				]);
			} catch (error) {
				console.error('Failed to fetch analytics data:', error);
			}
		};
		fetchData();
	}, [startDate, endDate, fetchTasksAnalytics, fetchUsersWorkload]);

	const handleTabChange = (event: React.SyntheticEvent, newValue: number) => {
		setTabValue(newValue);
	};

	return (
		<LocalizationProvider dateAdapter={AdapterDateFns} adapterLocale={ru}>
			<Container maxWidth="lg">
				<Box py={4}>
					<Typography variant="h4" gutterBottom>
						Аналитика
					</Typography>

					<Paper sx={{ mb: 4 }}>
						<Box p={2} display="flex" gap={2}>
							<DatePicker
								label="Начальная дата"
								value={startDate}
								onChange={(newValue) => setStartDate(newValue)}
								format="dd.MM.yyyy"
								slotProps={{
									textField: {
										size: "small",
										fullWidth: true
									}
								}}
							/>
							<DatePicker
								label="Конечная дата"
								value={endDate}
								onChange={(newValue) => setEndDate(newValue)}
								format="dd.MM.yyyy"
								slotProps={{
									textField: {
										size: "small",
										fullWidth: true
									}
								}}
							/>
						</Box>
					</Paper>

					<Paper>
						<Tabs
							value={tabValue}
							onChange={handleTabChange}
							indicatorColor="primary"
							textColor="primary"
						>
							<Tab label="Задачи" />
							<Tab label="Нагрузка" />
						</Tabs>

						<TabPanel value={tabValue} index={0}>
							<TasksAnalytics
								startDate={startDate}
								endDate={endDate}
								data={tasksAnalytics}
								isLoading={isLoading}
								error={error}
							/>
						</TabPanel>
						<TabPanel value={tabValue} index={1}>
							<UsersWorkload
								startDate={startDate}
								endDate={endDate}
								data={usersWorkload}
								isLoading={isLoading}
								error={error}
							/>
						</TabPanel>
					</Paper>
				</Box>
			</Container>
		</LocalizationProvider>
	);
};
