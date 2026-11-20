import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_providers.dart';
import '../../providers/profile_providers.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/state_views.dart';

/// Shown right after sign-in while the profile (and role) loads.
/// If it fails, the user can retry or sign out instead of being stuck.
class LoadingScreen extends ConsumerWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);

    return GradientScaffold(
      showAppBar: false,
      body: profile.hasError && !profile.isLoading
          ? Column(
              children: [
                Expanded(
                  child: ErrorView(
                    error: profile.error!,
                    onRetry: () => ref.invalidate(currentProfileProvider),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    onPressed: ref.read(authControllerProvider.notifier).signOut,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sign out'),
                  ),
                ),
              ],
            )
          : const LoadingView(message: 'Loading your account…'),
    );
  }
}
