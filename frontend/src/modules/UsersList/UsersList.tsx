'use client'
import { useUsers } from "@/shared/hooks/useUsers";
import { useEffect } from "react";
import { useSession } from "next-auth/react";
import styles from './UsersList.module.scss';

export const UsersList = () => {
	const { data: session } = useSession();
	const { users = [], loading, error, fetchUsers, deleteUser } = useUsers();

	useEffect(() => {
		if (session?.accessToken) {
			fetchUsers();
		}
	}, [session?.accessToken, fetchUsers]);

	const handleDelete = async (userId: string) => {
		if (window.confirm('Вы уверены, что хотите удалить этого пользователя?')) {
			try {
				await deleteUser(userId);
			} catch (error) {
				console.error('Error deleting user:', error);
			}
		}
	};

	const getRoleName = (role: string) => {
		const roles = {
			admin: 'Администратор',
			manager: 'Менеджер',
			developer: 'Разработчик'
		};
		return roles[role as keyof typeof roles] || role;
	};

	if (loading) return <div>Загрузка...</div>;
	if (error) return <div>Ошибка: {error}</div>;
	if (users.length === 0) return <div>Пользователи отсутствуют</div>;

	return (
		<div className={styles.usersList}>
			<h2>Список пользователей</h2>
			<div className={styles.usersGrid}>
				{users.map(user => (
					<div key={user.id} className={styles.userCard}>
						<div className={styles.userContent}>
							<div className={styles.userName}>
								{user.firstName} {user.lastName}
							</div>
							<div className={styles.userEmail}>{user.email}</div>
							<div className={styles.userRole}>
								Роль: {getRoleName(user.role)}
							</div>
						</div>
						<button
							className={styles.deleteButton}
							onClick={() => handleDelete(user.id)}
							title="Удалить пользователя"
						>
							✕
						</button>
					</div>
				))}
			</div>
		</div>
	);
};
