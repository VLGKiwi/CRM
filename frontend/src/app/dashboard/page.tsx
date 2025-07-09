'use client';

import { TaskList } from '@/modules/TaskList/TaskList';
import { UsersList } from '@/modules/UsersList/UsersList';
import styles from './page.module.css';
import { Analytics } from '@/modules/Analytics/Analytics';

export default function Dashboard() {
  return (
    <div className={styles.container}>
      <TaskList />
      <UsersList />
      <Analytics /> 
    </div>
  );
}
