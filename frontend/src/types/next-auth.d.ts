import 'next-auth';
import { DefaultSession } from 'next-auth';

declare module 'next-auth' {
	interface Session {
		accessToken: string;
		user: {
			id: string;
			email: string;
			name: string;
			role: string;
			firstName: string;
			lastName: string;
			teamId?: string;
		} & DefaultSession['user'];
	}

	interface User {
		id: string;
		email: string;
		name: string;
		role: string;
		firstName: string;
		lastName: string;
		teamId?: string;
		accessToken: string;
	}
}

declare module 'next-auth/jwt' {
	interface JWT {
		id: string;
		email: string;
		name: string;
		role: string;
		firstName: string;
		lastName: string;
		teamId?: string;
		accessToken: string;
	}
}
