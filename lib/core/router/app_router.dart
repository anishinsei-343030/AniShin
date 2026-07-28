import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/detail/screens/detail_screen.dart';
import '../../features/player/screens/player_screen.dart';
import '../../features/library/screens/library_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SearchScreen(),
            ),
          ),
          GoRoute(
            path: '/library',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: LibraryScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/anime/:id',
        builder: (context, state) => DetailScreen(
          id: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/watch/:animeId/:episodeId',
        builder: (context, state) => PlayerScreen(
          animeId: state.pathParameters['animeId']!,
          episodeId: state.pathParameters['episodeId']!,
          animeTitle: state.uri.queryParameters['title'],
          animeImage: state.uri.queryParameters['image'],
          episodeNumber: double.tryParse(state.uri.queryParameters['ep'] ?? '') ?? 1,
        ),
      ),
    ],
  );
});

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _NavBar(),
    );
  }
}

class _NavBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;
    if (location.startsWith('/search')) currentIndex = 1;
    if (location.startsWith('/library')) currentIndex = 2;
    if (location.startsWith('/settings')) currentIndex = 3;

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/search');
            break;
          case 2:
            context.go('/library');
            break;
          case 3:
            context.go('/settings');
            break;
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.search_outlined), label: 'Search'),
        NavigationDestination(icon: Icon(Icons.bookmark_outline), label: 'Library'),
        NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
      ],
    );
  }
}

