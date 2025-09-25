import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/init/screens/user_init_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'features/posts/screens/post_details_screen.dart';
import 'features/posts/screens/posts_screen.dart';

void main() {
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'RentX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: Color(0xFFffffff),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFffffff),
          surfaceTintColor: Color(0xFFffffff),
        ),
      ),
      // home: AuthScreen(),
      // home: HomeScreen(),
      routerConfig: createRouter(ref),
    );
  }
}

class RouteNames {
  static const String home = '/';
  static const String posts = '/posts';
  static const String postDetails = '/posts/:id';
}

// ---------------- Root Navigator Key ----------------
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

// ---------------- GoRouter ----------------
GoRouter createRouter(WidgetRef ref) => GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteNames.home,
  routes: [
    GoRoute(
      path: RouteNames.home,
      builder: (context, state) => UserInitScreen(),
    ),
    GoRoute(path: RouteNames.posts, builder: (context, state) => PostsScreen()),
    GoRoute(
      path: RouteNames.postDetails,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PostDetailsScreen(id: id);
      },
    ),
  ],
);
