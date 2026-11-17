import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../main.dart';
import '../state/auth_controller.dart';
import '../state/cart_controller.dart';
import '../state/products_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/credit_card.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/price_filter_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final shop = ProductsController.instance;

  @override
  void initState() {
    super.initState();
    // Loads price bounds + page 1 the first time; no-op afterwards,
    // so coming back from the cart keeps the user's filter and page.
    shop.init();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 700 ? 3 : 2;

    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: const Text('Game Credits Shop'),

        actions: [
          IconButton(
            onPressed: () {
              GameCreditsShop.of(context).toggleTheme();
            },
            icon: Icon(
              isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
          ),

          IconButton(
            onPressed: () {
              context.push('/cart');
            },
            icon: const Icon(Icons.shopping_cart),
          ),

          // Signed-in account + sign out.
          PopupMenuButton<String>(
            tooltip: 'Account',
            icon: const Icon(Icons.account_circle),
            onSelected: (value) async {
              if (value == 'signout') {
                CartController.instance.clear();
                // The router sends the user to /login once signed out.
                await AuthController.instance.signOut();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Text(
                  AuthController.instance.user?.email ?? 'Signed in',
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 10),
                    Text('Sign out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.darkGradient
              : AppTheme.lightGradient,
        ),

        child: SafeArea(
          // Rebuilds whenever ProductsController calls notifyListeners().
          child: ListenableBuilder(
            listenable: shop,
            builder: (context, _) {
              return Column(
                children: [
                  const SizedBox(height: 10),

                  const Text(
                    'Steam • Valorant',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Official Game Credits',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (shop.maxPrice > shop.minPrice)
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      child: PriceFilterPanel(controller: shop),
                    ),

                  const SizedBox(height: 10),

                  Expanded(child: _buildProducts(columns)),

                  if (shop.totalCount > 0)
                    PaginationBar(controller: shop),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProducts(int columns) {
    // First load: nothing to show yet.
    if (shop.isLoading && shop.products.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (shop.error != null) {
      return _Message(
        icon: Icons.cloud_off_rounded,
        text: shop.error!,
        actionLabel: 'Retry',
        onAction: shop.retry,
      );
    }

    if (shop.totalCount == 0) {
      return _Message(
        icon: Icons.search_off_rounded,
        text: 'No game credits in this price range.',
        actionLabel: shop.isFiltered ? 'Reset price filter' : null,
        onAction: shop.resetFilter,
      );
    }

    return Stack(
      children: [
        // Dim the current page while the next one loads,
        // instead of flashing an empty screen.
        AnimatedOpacity(
          opacity: shop.isLoading ? .4 : 1,
          duration: const Duration(milliseconds: 150),
          child: GridView.builder(
            // New key per page → the grid scrolls back to the top.
            key: ValueKey(shop.currentPage),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),

            itemCount: shop.products.length,

            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: .72,
            ),

            itemBuilder: (context, index) {
              final item = shop.products[index];

              return CreditCard(
                credit: item,
                onTap: () {
                  context.push('/detail/${item.id}', extra: item);
                },
              );
            },
          ),
        ),

        if (shop.isLoading)
          const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback onAction;

  const _Message({
    required this.icon,
    required this.text,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 56),

            const SizedBox(height: 12),

            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),

            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
