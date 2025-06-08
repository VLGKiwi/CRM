'use client';
import { useState } from 'react';
import { signIn } from 'next-auth/react';
import { useRouter, useSearchParams } from 'next/navigation';
import styles from './LoginForm.module.css';

export default function LoginForm() {
	const [email, setEmail] = useState('');
	const [password, setPassword] = useState('');
	const [error, setError] = useState('');
	const [isLoading, setIsLoading] = useState(false);
	const router = useRouter();
	const searchParams = useSearchParams();
	const callbackUrl = searchParams.get('callbackUrl') || '/dashboard';

	const handleSubmit = async (e: React.FormEvent) => {
		e.preventDefault();
		setError('');
		setIsLoading(true);

		try {
			const result = await signIn('credentials', {
				email,
				password,
				redirect: false,
			});

			console.log('SignIn result:', result);

			if (!result?.ok) {
				setError(result?.error || 'Ошибка авторизации');
			} else {
				router.push(callbackUrl);
				router.refresh();
			}
		} catch (error) {
			console.error('Login error:', error);
			setError('Произошла ошибка при входе');
		} finally {
			setIsLoading(false);
		}
	};

	return (
		<div className={styles.container}>
			<div className={styles.formWrapper}>
				<div>
					<h2 className={styles.title}>Вход в систему</h2>
				</div>
				<form className={styles.form} onSubmit={handleSubmit}>
					<div className={styles.inputGroup}>
						<div>
							<label htmlFor="email" className={styles.label}>
								Email
							</label>
							<input
								id="email"
								name="email"
								type="email"
								required
								className={styles.input}
								placeholder="Email"
								value={email}
								onChange={(e) => setEmail(e.target.value)}
								disabled={isLoading}
							/>
						</div>
						<div>
							<label htmlFor="password" className={styles.label}>
								Пароль
							</label>
							<input
								id="password"
								name="password"
								type="password"
								required
								className={styles.input}
								placeholder="Пароль"
								value={password}
								onChange={(e) => setPassword(e.target.value)}
								disabled={isLoading}
							/>
						</div>
					</div>

					{error && (
						<div className={styles.error}>{error}</div>
					)}

					<div>
						<button
							type="submit"
							disabled={isLoading}
							className={`${styles.button} ${isLoading ? styles.buttonLoading : ''}`}
						>
							{isLoading ? 'Вход...' : 'Войти'}
						</button>
					</div>
				</form>
			</div>
		</div>
	);
}
