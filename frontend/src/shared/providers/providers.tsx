'use client';

import { SessionProvider, signOut, useSession } from 'next-auth/react';
import { useEffect } from 'react';
import { useRouter } from 'next/navigation';

function TokenErrorHandler({ children }: { children: React.ReactNode }) {
	const { data: session } = useSession();
	const router = useRouter();

	useEffect(() => {
		if (session?.error === 'RefreshAccessTokenError') {
			signOut({ callbackUrl: '/login' });
		}
	}, [session]);

	return <>{children}</>;
}

export function NextAuthProvider({ children }: { children: React.ReactNode }) {
	return (
		<SessionProvider>
			<TokenErrorHandler>{children}</TokenErrorHandler>
		</SessionProvider>
	);
}
