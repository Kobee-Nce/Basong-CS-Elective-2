import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'models/game_credit.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_confirmation_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_detail_screen.dart';
import 'state/products_controller.dart';
import 'theme/app_theme.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),

    GoRoute(
      path: '/detail/:id',
      builder: (context, state) {
        // Normal case: the home grid passes the product it already loaded.
        final extra = state.extra;
        if (extra is GameCredit) {
          return ProductDetailScreen(credit: extra);
        }

        // Opened directly by URL (e.g. a refresh on web): fetch it by id.
        final id = int.parse(state.pathParameters['id']!);
        return _DetailLoader(id: id);
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

class _DetailLoader extends StatefulWidget {
  final int id;

  const _DetailLoader({required this.id});

  @override
  State<_DetailLoader> createState() => _DetailLoaderState();
}

class _DetailLoaderState extends State<_DetailLoader> {
  // Created once, so rebuilds don't re-run the query.
  late final Future<GameCredit?> _future =
      ProductsController.instance.fetchById(widget.id);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GameCredit?>(
      future: _future,
      builder: (context, snapshot) {
        final credit = snapshot.data;
        if (credit != null) {
          return ProductDetailScreen(credit: credit);
        }

        final done = snapshot.connectionState == ConnectionState.done;

        return Scaffold(
          appBar: AppBar(),
          extendBodyBehindAppBar: true,
          body: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.lightGradient,
            ),
            child: Center(
              child: done
                  ? const Text(
                      'Product not found.',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )
                  : const CircularProgressIndicator(color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
