import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/profile.dart';
import '../../providers/auth_providers.dart';
import '../../providers/profile_providers.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/state_views.dart';

/// Account details. Customers can edit their first/last name (their
/// own row only; the role can't be changed — the database refuses it).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);

    return GradientScaffold(
      title: const Text('Profile'),
      body: AsyncValueView<Profile?>(
        value: profile,
        onRetry: () => ref.invalidate(currentProfileProvider),
        isEmpty: (p) => p == null,
        empty: const MessageView(icon: Icons.person_off_rounded, message: 'Not signed in.'),
        data: (p) => Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: _ProfileForm(profile: p!),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileForm extends ConsumerStatefulWidget {
  final Profile profile;

  const _ProfileForm({required this.profile});

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _first =
      TextEditingController(text: widget.profile.firstname ?? '');
  late final TextEditingController _last =
      TextEditingController(text: widget.profile.lastname ?? '');

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(profileControllerProvider.notifier).updateName(
          firstname: _first.text.trim(),
          lastname: _last.text.trim(),
        );
    if (!mounted) return;
    if (ok) {
      showMessage(context, 'Profile saved.');
    } else {
      final error = ref.read(profileControllerProvider).error;
      showMessage(context, error?.toString() ?? 'Could not save.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    final saving = ref.watch(profileControllerProvider).isLoading;
    final canEdit = p.isCustomer;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CircleAvatar(
                radius: 34,
                child: Text(
                  p.fullName.isNotEmpty ? p.fullName[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 30),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                p.email ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 6),
              Center(
                child: Chip(
                  avatar: Icon(
                    p.isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                    size: 18,
                  ),
                  label: Text(p.isAdmin ? 'Admin' : 'Customer'),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _first,
                enabled: canEdit && !saving,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'First name'),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Enter your first name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _last,
                enabled: canEdit && !saving,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Last name'),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Enter your last name' : null,
              ),
              const SizedBox(height: 16),
              if (canEdit)
                ElevatedButton(
                  onPressed: saving ? null : _save,
                  child: saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('Save'),
                )
              else
                const Text(
                  'Admin profiles are read-only in the app.',
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: ref.read(authControllerProvider.notifier).signOut,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
