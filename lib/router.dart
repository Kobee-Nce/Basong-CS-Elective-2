import 'package:go_router/go_router.dart';

import 'data/game_credits.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_confirmation_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_detail_screen.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),

    GoRoute(
      path: '/detail/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);

        final item = credits.firstWhere(
          (credit) => credit.id == id,
        );

        return ProductDetailScreen(credit: item);
      },
    ),

    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartScreen(),
    ),

    GoRoute(
      path: '/checkout',
      builder: (context, state) =>
          const CheckoutConfirmationScreen(),
    ),
  ],
);