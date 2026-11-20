import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/product.dart';
import '../providers/auth_providers.dart';
import '../providers/profile_providers.dart';
import '../screens/admin/admin_categories_screen.dart';
import '../screens/admin/admin_orders_screen.dart';
import '../screens/admin/admin_products_screen.dart';
import '../screens/admin/product_form_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/common/denied_screen.dart';
import '../screens/common/loading_screen.dart';
import '../screens/common/profile_screen.dart';
import '../screens/common/role_shell.dart';
import '../screens/customer/cart_screen.dart';
import '../screens/customer/checkout_confirmation_screen.dart';
import '../screens/customer/order_history_screen.dart';
import '../screens/customer/product_detail_screen.dart';
import '../screens/customer/shop_screen.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/state_views.dart';

/// Pages only customers may open (admins can't shop or order).
const _customerPages = ['/shop', '/cart', '/orders', '/product/', '/checkout/'];

/// Re-runs the router's redirect when the session or profile changes.
class _RouterRefresh extends ChangeNotifier {
  void notify() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh();
  ref.listen(currentUserIdProvider, (_, _) => refresh.notify());
  ref.listen(currentProfileProvider, (_, _) => refresh.notify());

  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) => _redirect(ref, state),
    // Unknown paths (including the Google redirect link, which Supabase
    // handles itself) go home; the redirect then picks the right page.
    onException: (context, state, router) => router.go('/'),
    routes: [
      GoRoute(path: '/', builder: (_, _) => const LoadingScreen()),
      GoRoute(path: '/loading', builder: (_, _) => const LoadingScreen()),
      GoRoute(
        path: '/login',
        builder: (_, state) => LoginScreen(
          notice: state.extra is String ? state.extra as String : null,
        ),
      ),
      GoRoute(path: '/signup', builder: (_, _) => const SignupScreen()),
      GoRoute(path: '/denied', builder: (_, _) => const DeniedScreen()),
      GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),

      // ---------------- Customer ----------------
      GoRoute(
        path: '/product/:id',
        builder: (_, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) return const _NotFound();
          final extra = state.extra;
          return ProductDetailScreen(
            productId: id,
            initial: extra is Product && extra.id == id ? extra : null,
          );
        },
      ),
      GoRoute(
        path: '/checkout/:orderId',
        builder: (_, state) {
          final id = int.tryParse(state.pathParameters['orderId'] ?? '');
          if (id == null) return const _NotFound();
          return CheckoutConfirmationScreen(orderId: id);
        },
      ),
      ShellRoute(
        builder: (_, state, child) =>
            CustomerShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(path: '/shop', builder: (_, _) => const ShopScreen()),
          GoRoute(path: '/cart', builder: (_, _) => const CartScreen()),
          GoRoute(path: '/orders', builder: (_, _) => const OrderHistoryScreen()),
        ],
      ),

      // ---------------- Admin ----------------
      GoRoute(
        path: '/admin/products/new',
        builder: (_, _) => const ProductFormScreen(),
      ),
      GoRoute(
        path: '/admin/products/:id/edit',
        builder: (_, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) return const _NotFound();
          final extra = state.extra;
          return ProductFormScreen(
            productId: id,
            initial: extra is Product && extra.id == id ? extra : null,
          );
        },
      ),
      ShellRoute(
        builder: (_, state, child) =>
            AdminShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: '/admin/products',
            builder: (_, _) => const AdminProductsScreen(),
          ),
          GoRoute(
            path: '/admin/categories',
            builder: (_, _) => const AdminCategoriesScreen(),
          ),
          GoRoute(
            path: '/admin/orders',
            builder: (_, _) => const AdminOrdersScreen(),
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });

  return router;
});

/// The auth gate + role gate.
///   signed out          → only /login and /signup
///   profile not loaded  → /loading (shows errors with Retry / Sign out)
///   admin               → /admin/...   (customer pages → /denied)
///   customer            → shop pages   (admin pages → /denied)
String? _redirect(Ref ref, GoRouterState state) {
  final location = state.matchedLocation;
  final onAuthPage = location == '/login' || location == '/signup';

  final userId = ref.read(currentUserIdProvider);
  if (userId == null) return onAuthPage ? null : '/login';

  final profile = ref.read(currentProfileProvider).value;
  if (profile == null) return location == '/loading' ? null : '/loading';

  final home = profile.isAdmin ? '/admin/products' : '/shop';
  if (onAuthPage || location == '/' || location == '/loading') return home;

  final adminPage = location.startsWith('/admin');
  final customerPage = _customerPages.any(location.startsWith);

  if (adminPage && !profile.isAdmin) return '/denied';
  if (customerPage && profile.isAdmin) return '/denied';
  return null;
}

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: const Text('Not found'),
      body: MessageView(
        icon: Icons.explore_off_rounded,
        title: 'Page not found',
        message: "This page doesn't exist.",
        actionLabel: 'Go to home',
        onAction: () => context.go('/'),
      ),
    );
  }
}
