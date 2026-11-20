import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';
import '../providers/profile_providers.dart';
import '../providers/theme_provider.dart';

/// Theme toggle + account menu (profile, sign out) for every app bar.
class AppBarActions extends ConsumerWidget {
  const AppBarActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final profile = ref.watch(currentProfileProvider).value;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: isDark ? 'Light mode' : 'Dark mode',
          onPressed: ref.read(themeModeProvider.notifier).toggle,
          icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
        ),
        PopupMenuButton<String>(
          tooltip: 'Account',
          icon: const Icon(Icons.account_circle_rounded),
          onSelected: (value) async {
            if (value == 'profile') {
              context.push('/profile');
            } else if (value == 'signout') {
              await ref.read(authControllerProvider.notifier).signOut();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?.fullName ?? 'Signed in',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${profile?.email ?? ''} • ${profile?.isAdmin == true ? 'Admin' : 'Customer'}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'profile',
              child: Row(
                children: [Icon(Icons.person_rounded), SizedBox(width: 10), Text('Profile')],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'signout',
              child: Row(
                children: [Icon(Icons.logout_rounded), SizedBox(width: 10), Text('Sign out')],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
