import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/cart_provider.dart';

class _Tab {
  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _Tab(this.path, this.label, this.icon, this.selectedIcon);
}

/// Bottom navigation for customers: Shop / Cart / Orders.
class CustomerShell extends ConsumerWidget {
  final String location;
  final Widget child;

  const CustomerShell({super.key, required this.location, required this.child});

  static const _tabs = [
    _Tab('/shop', 'Shop', Icons.storefront_outlined, Icons.storefront_rounded),
    _Tab('/cart', 'Cart', Icons.shopping_cart_outlined, Icons.shopping_cart_rounded),
    _Tab('/orders', 'Orders', Icons.receipt_long_outlined, Icons.receipt_long_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartCountProvider);
    return _Shell(
      tabs: _tabs,
      location: location,
      badges: {'/cart': count},
      child: child,
    );
  }
}

/// Bottom navigation for admins: Products / Categories / Orders.
class AdminShell extends StatelessWidget {
  final String location;
  final Widget child;

  const AdminShell({super.key, required this.location, required this.child});

  static const _tabs = [
    _Tab('/admin/products', 'Products', Icons.inventory_2_outlined, Icons.inventory_2_rounded),
    _Tab('/admin/categories', 'Categories', Icons.category_outlined, Icons.category_rounded),
    _Tab('/admin/orders', 'Orders', Icons.receipt_long_outlined, Icons.receipt_long_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return _Shell(tabs: _tabs, location: location, child: child);
  }
}

class _Shell extends StatelessWidget {
  final List<_Tab> tabs;
  final String location;
  final Map<String, int> badges;
  final Widget child;

  const _Shell({
    required this.tabs,
    required this.location,
    required this.child,
    this.badges = const {},
  });

  @override
  Widget build(BuildContext context) {
    final index = tabs.indexWhere((t) => location.startsWith(t.path));

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index < 0 ? 0 : index,
        onDestinationSelected: (i) => context.go(tabs[i].path),
        destinations: [
          for (final tab in tabs)
            NavigationDestination(
              label: tab.label,
              icon: _icon(tab.icon, badges[tab.path] ?? 0),
              selectedIcon: _icon(tab.selectedIcon, badges[tab.path] ?? 0),
            ),
        ],
      ),
    );
  }

  Widget _icon(IconData icon, int badge) => Badge(
        isLabelVisible: badge > 0,
        label: Text('$badge'),
        child: Icon(icon),
      );
}
