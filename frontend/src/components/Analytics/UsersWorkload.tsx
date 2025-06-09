import React from 'react';
import {
	Table,
	TableBody,
	TableCell,
	TableContainer,
	TableHead,
	TableRow,
	Paper,
	Typography,
	Box,
	CircularProgress,
	Chip,
} from '@mui/material';

interface UserWorkload {
	name: string;
	role: string;
	roles_in_tasks: string;
	total_tasks: string;
	completed_tasks: string;
	completion_rate: string;
	total_estimated_hours: string;
	total_actual_hours: string;
	efficiency_ratio: string;
}

interface UsersWorkloadProps {
	startDate: Date | null;
	endDate: Date | null;
	data: UserWorkload[];
	isLoading: boolean;
	error: string | null;
}

export const UsersWorkload: React.FC<UsersWorkloadProps> = ({
	data: usersWorkload,
	isLoading,
	error
}) => {
	if (isLoading) {
		return (
			<Box display="flex" justifyContent="center" alignItems="center" minHeight="200px">
				<CircularProgress />
			</Box>
		);
	}

	if (error) {
		return (
			<Box p={2}>
				<Typography color="error">
					Ошибка при загрузке данных о нагрузке: {error}
				</Typography>
			</Box>
		);
	}

	const formatRole = (role: string): string => {
		const roleMap: { [key: string]: string } = {
			'developer': 'Разработчик',
			'team_lead': 'Тимлид',
			'manager': 'Менеджер',
			'sales': 'Продажи',
			'admin': 'Администратор'
		};
		return roleMap[role] || role;
	};

	const getEfficiencyColor = (ratio: string): "success" | "warning" | "error" => {
		const value = parseFloat(ratio);
		if (value >= 0.8) return "success";
		if (value >= 0.5) return "warning";
		return "error";
	};

	return (
		<Box p={2}>
			<Typography variant="h5" gutterBottom>
				Нагрузка сотрудников
			</Typography>

			<TableContainer component={Paper}>
				<Table>
					<TableHead>
						<TableRow>
							<TableCell>Сотрудник</TableCell>
							<TableCell>Роль</TableCell>
							<TableCell>Роли в задачах</TableCell>
							<TableCell align="right">Всего задач</TableCell>
							<TableCell align="right">Выполнено</TableCell>
							<TableCell align="right">% выполнения</TableCell>
							<TableCell align="right">План (ч)</TableCell>
							<TableCell align="right">Факт (ч)</TableCell>
							<TableCell align="right">Эффективность</TableCell>
						</TableRow>
					</TableHead>
					<TableBody>
						{usersWorkload?.map((row: UserWorkload, index: number) => (
							<TableRow key={index}>
								<TableCell>{row.name}</TableCell>
								<TableCell>{formatRole(row.role)}</TableCell>
								<TableCell>{row.roles_in_tasks}</TableCell>
								<TableCell align="right">{row.total_tasks}</TableCell>
								<TableCell align="right">{row.completed_tasks}</TableCell>
								<TableCell align="right">{row.completion_rate}</TableCell>
								<TableCell align="right">{row.total_estimated_hours}</TableCell>
								<TableCell align="right">{row.total_actual_hours}</TableCell>
								<TableCell align="right">
									<Chip
										label={row.efficiency_ratio}
										color={getEfficiencyColor(row.efficiency_ratio)}
										size="small"
									/>
								</TableCell>
							</TableRow>
						))}
					</TableBody>
				</Table>
			</TableContainer>
		</Box>
	);
};
