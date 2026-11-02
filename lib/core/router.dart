import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';

const _authPaths = {'/login', '/register', '/forgot-password'};

/// Rotas do app. O `redirect` manda o usuário para a tela certa conforme o
/// estado de login (sessão persistente: reabrir o app logado vai direto à Home).
GoRouter createRouter(AuthProvider auth) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: auth,
    redirect: (context, state) {
      final path = state.matchedLocation;
      if (!auth.isReady) return path == '/splash' ? null : '/splash';
      if (!auth.isLoggedIn) return _authPaths.contains(path) ? null : '/login';
      if (_authPaths.contains(path) || path == '/splash') return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
      GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
    ],
  );
}
