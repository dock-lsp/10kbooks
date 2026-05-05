import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/books/screens/home_screen.dart';
import '../../features/books/screens/book_detail_screen.dart';
import '../../features/reader/screens/reader_screen.dart';

/// App Router Configuration
class AppRouter {
  final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Home
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Book Detail
      GoRoute(
        path: '/book/:id',
        name: 'bookDetail',
        builder: (context, state) {
          final bookId = state.pathParameters['id']!;
          return BookDetailScreen(bookId: bookId);
        },
      ),

      // Reader
      GoRoute(
        path: '/reader/:bookId/:chapterId',
        name: 'reader',
        builder: (context, state) {
          final bookId = state.pathParameters['bookId']!;
          final chapterId = state.pathParameters['chapterId']!;
          final extra = state.extra as Map<String, dynamic>?;
          return ReaderScreen(
            bookId: bookId,
            chapterId: chapterId,
            chapterIndex: extra?['chapterIndex'] ?? 0,
          );
        },
      ),

      // Search
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Search Screen')),
        ),
      ),

      // Notifications
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Notifications Screen')),
        ),
      ),

      // Settings
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Settings Screen')),
        ),
      ),

      // Profile
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Profile Screen')),
        ),
      ),

      // Login
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Login Screen')),
        ),
      ),

      // Register
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Register Screen')),
        ),
      ),

      // Author Center
      GoRoute(
        path: '/author-center',
        name: 'authorCenter',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Author Center Screen')),
        ),
      ),

      // Bookshelf
      GoRoute(
        path: '/bookshelf',
        name: 'bookshelf',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Bookshelf Screen')),
        ),
      ),

      // Social/Dynamics
      GoRoute(
        path: '/social',
        name: 'social',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Social Screen')),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri.path}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
