import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/profile_providers.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/state_views.dart';

/// Shown when a signed-in user opens a page that isn't for their role
/// (e.g. a customer typing /admin/products on web).
class DeniedScreen extends ConsumerWidget {
  const DeniedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(currentProfileProvider).value?.isAdmin ?? false;

    return GradientScaffold(
      title: const Text('Permission denied'),
      body: MessageView(
        icon: Icons.lock_outline_rounded,
        title: 'Permission denied',
        message: isAdmin
            ? 'This page is for customers. Admin accounts manage the shop '
                'but cannot shop or place orders.'
            : 'This page is for admins only.',
        actionLabel: 'Go to home',
        onAction: () => context.go(isAdmin ? '/admin/products' : '/shop'),
      ),
    );
  }
}
