'use client';

import { TaskList } from '@/modules/TaskList/TaskList';
import styles from './page.module.css';

export default function Dashboard() {
  return (
    <div className={styles.container}>
      <TaskList />
    </div>
  );
}
