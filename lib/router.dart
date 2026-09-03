import 'package:go_router/go_router.dart';

import 'data/game_credits.dart';
import 'screens/home_screen.dart';
import 'screens/product_detail_screen.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/detail/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final item = credits.firstWhere((e) => e.id == id);

        return ProductDetailScreen(credit: item);
      },
    ),
  ],
);