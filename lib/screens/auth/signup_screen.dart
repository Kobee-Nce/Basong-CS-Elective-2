import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_providers.dart';
import 'auth_widgets.dart';

/// Create an account. Every new account is a customer — the
/// handle_new_user() trigger creates the profile with that role.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstname = TextEditingController();
  final _lastname = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _firstname.dispose();
    _lastname.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _email.text.trim();
    final controller = ref.read(authControllerProvider.notifier);
    final signedIn = await controller.signUp(
      email: email,
      password: _password.text,
      firstname: _firstname.text.trim(),
      lastname: _lastname.text.trim(),
    );

    if (!mounted) return;
    final failed = ref.read(authControllerProvider).hasError;

    // Email confirmation is on: no session yet → back to sign in.
    if (!signedIn && !failed) {
      context.go(
        '/login',
        extra: 'Account created! Check $email for a confirmation link, '
            'then sign in.',
      );
    }
    // When signed in right away, the router moves on by itself.
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final busy = auth.isLoading;

    String? requiredField(String? v, String what) =>
        (v ?? '').trim().isEmpty ? 'Enter your $what' : null;

    return AuthLayout(
      subtitle: 'Create your account',
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstname,
                      enabled: !busy,
                      autofillHints: const [AutofillHints.givenName],
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'First name'),
                      validator: (v) => requiredField(v, 'first name'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _lastname,
                      enabled: !busy,
                      autofillHints: const [AutofillHints.familyName],
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Last name'),
                      validator: (v) => requiredField(v, 'last name'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _email,
                enabled: !busy,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: validateEmail,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _password,
                enabled: !busy,
                obscureText: _hidePassword,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _hidePassword = !_hidePassword),
                    icon: Icon(
                      _hidePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (v) {
                  if ((v ?? '').isEmpty) return 'Enter a password';
                  // Supabase's default minimum length.
                  if (v!.length < 6) return 'Use at least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirm,
                enabled: !busy,
                obscureText: _hidePassword,
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                  prefixIcon: Icon(Icons.lock_reset_outlined),
                ),
                validator: (v) =>
                    v != _password.text ? 'Passwords do not match' : null,
              ),
              if (auth.hasError) ...[
                const SizedBox(height: 14),
                AuthNotice(text: auth.error.toString()),
              ],
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: busy ? null : _submit,
                child: buttonChild(busy, 'Create account'),
              ),
              const OrDivider(),
              GoogleButton(
                onPressed: busy
                    ? null
                    : ref.read(authControllerProvider.notifier).signInWithGoogle,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: busy
                    ? null
                    : () {
                        ref.read(authControllerProvider.notifier).clearError();
                        context.go('/login');
                      },
                child: const Text('Already have an account? Sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
