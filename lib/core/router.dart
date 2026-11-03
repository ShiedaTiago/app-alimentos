import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/household_provider.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/household/household_screen.dart';
import '../screens/household/household_setup_screen.dart';
import '../screens/items/item_form_screen.dart';
import '../screens/items/item_list_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/recipes/recipe_detail_screen.dart';
import '../screens/recipes/recipes_screen.dart';
import '../screens/scanner/barcode_scan_screen.dart';
import '../widgets/main_shell.dart';

const _authPaths = {'/login', '/register', '/forgot-password'};
const _setupPath = '/household/setup';

/// Rotas do app. O `redirect` manda o usuário para a tela certa conforme o
/// estado de login e de casa (sessão persistente: reabrir o app logado vai
/// direto à Home).
GoRouter createRouter(AuthProvider auth, HouseholdProvider household) {
  return GoRouter(
    initialLocation: '/splash',
    // Reavalia o redirect quando o login OU a casa mudam.
    refreshListenable: Listenable.merge([auth, household]),
    redirect: (context, state) {
      final path = state.matchedLocation;
      if (!auth.isReady) return path == '/splash' ? null : '/splash';
      if (!auth.isLoggedIn) return _authPaths.contains(path) ? null : '/login';
      if (!household.isReady) return path == '/splash' ? null : '/splash';
      if (!household.hasHousehold) {
        return path == _setupPath ? null : _setupPath;
      }
      if (_authPaths.contains(path) ||
          path == '/splash' ||
          path == _setupPath) {
        return '/home';
      }
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
      // Abas com barra inferior. As telas fora daqui (formulário, casa) abrem
      // por cima, em tela cheia.
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => MainShell(shell: shell),
        branches: [
          _tab('/home', const HomeScreen()),
          _tab('/items', const ItemListScreen()),
          _tab('/recipes', const RecipesScreen()),
          _tab('/profile', const ProfileScreen()),
        ],
      ),
      GoRoute(path: '/household', builder: (_, _) => const HouseholdScreen()),
      GoRoute(path: '/items/new', builder: (_, _) => const ItemFormScreen()),
      GoRoute(path: '/scanner', builder: (_, _) => const BarcodeScanScreen()),
      GoRoute(
        path: '/items/:id/edit',
        builder: (_, state) =>
            ItemFormScreen(itemId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/recipes/:id',
        builder: (_, state) =>
            RecipeDetailScreen(recipeId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: _setupPath,
        builder: (_, _) => const HouseholdSetupScreen(),
      ),
    ],
  );
}

StatefulShellBranch _tab(String path, Widget screen) => StatefulShellBranch(
  routes: [GoRoute(path: path, builder: (_, _) => screen)],
);
