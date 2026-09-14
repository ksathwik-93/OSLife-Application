import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/tasks/tasks_screen.dart';
import '../screens/notes/notes_screen.dart';
import '../screens/expense/expense_tracker_screen.dart';
import '../screens/goals/goals_screen.dart';
import '../screens/study/study_planner_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/search/global_search_screen.dart';
import '../widgets/bottom_nav_scaffold.dart';

/// AppRoutes defines all GoRouter routes and redirect logic for LifeOS.
class AppRoutes {
  AppRoutes._();

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: authProvider,
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        // Main shell with bottom navigation
        GoRoute(
          path: '/home',
          builder: (context, state) => const BottomNavScaffold(initialIndex: 0),
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const BottomNavScaffold(initialIndex: 1),
        ),
        GoRoute(
          path: '/ai',
          builder: (context, state) => const BottomNavScaffold(initialIndex: 2),
        ),
        GoRoute(
          path: '/analytics',
          builder: (context, state) => const BottomNavScaffold(initialIndex: 3),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const BottomNavScaffold(initialIndex: 4),
        ),
        // Detail / feature screens
        GoRoute(
          path: '/tasks',
          builder: (context, state) => const TasksScreen(),
        ),
        GoRoute(
          path: '/notes',
          builder: (context, state) => const NotesScreen(),
        ),
        GoRoute(
          path: '/expense',
          builder: (context, state) => const ExpenseTrackerScreen(),
        ),
        GoRoute(
          path: '/goals',
          builder: (context, state) => const GoalsScreen(),
        ),
        GoRoute(
          path: '/study',
          builder: (context, state) => const StudyPlannerScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) {
            final q = state.uri.queryParameters['q'];
            return GlobalSearchScreen(initialQuery: q);
          },
        ),
      ],
      redirect: (BuildContext context, GoRouterState state) {
        final loc = state.matchedLocation;
        final bool isLoggedIn = authProvider.isAuthenticated;

        // Allow splash screen to finish naturally
        if (loc == '/splash' || loc == '/onboarding') {
          return null;
        }

        final bool isAuthRoute = loc == '/login' || loc == '/register' || loc == '/forgot-password';

        // If not logged in and attempting to access protected routes -> send to /login
        if (!isLoggedIn && !isAuthRoute) {
          return '/login';
        }

        // If logged in and attempting to access auth routes -> send to /home
        if (isLoggedIn && isAuthRoute) {
          return '/home';
        }

        return null;
      },
    );
  }

  static final List<RouteBase> routes = [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const BottomNavScaffold(initialIndex: 0),
    ),
    GoRoute(
      path: '/calendar',
      builder: (context, state) => const BottomNavScaffold(initialIndex: 1),
    ),
    GoRoute(
      path: '/ai',
      builder: (context, state) => const BottomNavScaffold(initialIndex: 2),
    ),
    GoRoute(
      path: '/analytics',
      builder: (context, state) => const BottomNavScaffold(initialIndex: 3),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const BottomNavScaffold(initialIndex: 4),
    ),
    GoRoute(
      path: '/tasks',
      builder: (context, state) => const TasksScreen(),
    ),
    GoRoute(
      path: '/notes',
      builder: (context, state) => const NotesScreen(),
    ),
    GoRoute(
      path: '/expense',
      builder: (context, state) => const ExpenseTrackerScreen(),
    ),
    GoRoute(
      path: '/goals',
      builder: (context, state) => const GoalsScreen(),
    ),
    GoRoute(
      path: '/study',
      builder: (context, state) => const StudyPlannerScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ];
}
