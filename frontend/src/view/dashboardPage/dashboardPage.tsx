import { TaskList } from "@/modules/TaskList/TaskList"
import { UsersList } from "@/modules/UsersList/UsersList"

export const DashboardPage = () => {
	return (
		<>
			<TaskList />
			<UsersList />
		</>
	)
}
