import { UUID } from 'crypto';
import NextAuth from 'next-auth';
import CredentialsProvider from 'next-auth/providers/credentials';

const handler = NextAuth({
	providers: [
		CredentialsProvider({
			name: 'Credentials',
			credentials: {
				email: { label: "Email", type: "email" },
				password: { label: "Password", type: "password" }
			},
			async authorize(credentials) {
				if (!credentials?.email || !credentials?.password) {
					throw new Error('Email и пароль обязательны');
				}

				try {
					const res = await fetch('http://localhost:3001/api/auth/login', {
						method: 'POST',
						headers: {
							'Content-Type': 'application/json'
						},
						body: JSON.stringify({
							email: credentials.email,
							password: credentials.password,
						}),
					});

					const data = await res.json();

					if (!res.ok) {
						throw new Error(data.message || 'Ошибка авторизации');
					}

					if (data.user) {
						return {
							id: data.user.id,
							email: data.user.email,
							name: `${data.user.firstName} ${data.user.lastName}`,
							firstName: data.user.firstName,
							lastName: data.user.lastName,
							role: data.user.role,
							teamId: data.user.teamId,
							accessToken: data.token,
						};
					}

					return null;
				} catch (error) {
					console.error('Auth error:', error);
					throw new Error('Ошибка при попытке входа');
				}
			}
		})
	],
	callbacks: {
		async jwt({ token, user }) {
			if (user) {
				token.id = (user as any).id;
				token.role = (user as any).role;
				token.firstName = (user as any).firstName;
				token.lastName = (user as any).lastName;
				token.teamId = (user as any).teamId;
				token.accessToken = (user as any).accessToken;
			}
			return token;
		},
		async session({ session, token }) {
			if (token) {
				(session.user as any).id = token.id;
				(session.user as any).role = token.role;
				(session.user as any).firstName = token.firstName;
				(session.user as any).lastName = token.lastName;
				(session.user as any).teamId = token.teamId;
				session.accessToken = token.accessToken;
			}
			return session;
		}
	},
	pages: {
		signIn: '/login',
		error: '/login',
	},
	session: {
		strategy: 'jwt',
		maxAge: 24 * 60 * 60, // 24 hours
	},
	debug: process.env.NODE_ENV === 'development',
});

export { handler as GET, handler as POST };
