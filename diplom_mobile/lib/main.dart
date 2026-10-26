import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'core/auth/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/student/screens/student_home_screen.dart';
import 'features/curator/screens/curator_home_screen.dart';
import 'features/vice_dean/screens/vice_dean_home_screen.dart';
import 'features/admin/screens/admin_home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final router = GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final loggedIn = authProvider.isAuthenticated;
        final onLogin = state.matchedLocation == '/login';

        if (!loggedIn && !onLogin) return '/login';
        if (loggedIn && onLogin) {
          final role = authProvider.role.toLowerCase();
          if (role.contains('студент') || role.contains('student')) return '/student';
          if (role.contains('куратор') || role.contains('curator')) return '/curator';
          if (role.contains('замдекана') || role.contains('зам') || role.contains('vicedean') || role.contains('vice')) return '/vicedean';
          if (role.contains('admin')) return '/admin';
          return '/login';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/student', builder: (_, __) => const StudentHomeScreen()),
        GoRoute(path: '/curator', builder: (_, __) => const CuratorHomeScreen()),
        GoRoute(path: '/vicedean', builder: (_, __) => const ViceDeanHomeScreen()),
        GoRoute(path: '/admin', builder: (_, __) => const AdminHomeScreen()),
      ],
    );

    return MaterialApp.router(
      title: 'DIPLOM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1565C0),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      routerConfig: router,
    );
  }
}
