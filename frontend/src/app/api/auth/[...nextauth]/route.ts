import { UUID } from 'crypto';
import NextAuth from 'next-auth';
import CredentialsProvider from 'next-auth/providers/credentials';

if (!process.env.NEXTAUTH_SECRET) {
	throw new Error('Please provide NEXTAUTH_SECRET environment variable');
}

const handler = NextAuth({
	secret: process.env.NEXTAUTH_SECRET,
	providers: [
		CredentialsProvider({
			id: 'credentials',
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
					const baseUrl = process.env.NEXT_PUBLIC_API_URL?.replace(/\/+$/, '').replace(/\/api$/, '');
					console.log('Base URL:', baseUrl);
					console.log('Attempting login with:', credentials.email);

					const res = await fetch(`${baseUrl}/api/auth/login`, {
						method: 'POST',
						headers: {
							'Content-Type': 'application/json',
						},
						body: JSON.stringify({
							email: credentials.email,
							password: credentials.password,
						}),
					});

					const data = await res.json().catch(() => null);
					console.log('Login response:', data);

					if (!res.ok) {
						throw new Error(data?.message || 'Ошибка авторизации');
					}

					if (!data?.token || !data?.user) {
						throw new Error('Неверный формат ответа от сервера');
					}

					return {
						id: data.user.id,
						email: data.user.email,
						name: `${data.user.firstName} ${data.user.lastName}`,
						firstName: data.user.firstName,
						lastName: data.user.lastName,
						role: data.user.role,
						teamId: data.user.teamId,
						accessToken: data.token
					};
				} catch (error: any) {
					console.error('Auth error:', error);
					throw new Error(error.message || 'Ошибка при попытке входа');
				}
			}
		})
	],
	callbacks: {
		async jwt({ token, user }) {
			if (user) {
				token.id = user.id;
				token.email = user.email;
				token.name = user.name;
				token.role = user.role;
				token.firstName = user.firstName;
				token.lastName = user.lastName;
				token.teamId = user.teamId;
				token.accessToken = user.accessToken;
			}
			return token;
		},
		async session({ session, token }) {
			if (token) {
				session.user.id = token.id;
				session.user.email = token.email;
				session.user.name = token.name;
				session.user.role = token.role;
				session.user.firstName = token.firstName;
				session.user.lastName = token.lastName;
				session.user.teamId = token.teamId;
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
