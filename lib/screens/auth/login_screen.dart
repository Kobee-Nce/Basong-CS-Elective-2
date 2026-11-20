import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_providers.dart';
import 'auth_widgets.dart';

/// Email + password sign in, plus "Continue with Google".
/// The router leaves this page on its own once a session exists.
class LoginScreen extends ConsumerStatefulWidget {
  /// Shown after sign-up when the email still needs confirming.
  final String? notice;

  const LoginScreen({super.key, this.notice});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).signIn(
          email: _email.text.trim(),
          password: _password.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final busy = auth.isLoading;

    // Errors from the Google redirect arrive through the auth stream.
    final streamError = ref.watch(authStateChangesProvider).error;
    final error = auth.error ?? streamError;

    return AuthLayout(
      subtitle: 'Sign in to continue',
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => _submit(),
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
                validator: (v) =>
                    (v ?? '').isEmpty ? 'Enter your password' : null,
              ),
              if (widget.notice != null && error == null) ...[
                const SizedBox(height: 14),
                AuthNotice(text: widget.notice!, isError: false),
              ],
              if (error != null) ...[
                const SizedBox(height: 14),
                AuthNotice(text: error.toString()),
              ],
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: busy ? null : _submit,
                child: buttonChild(busy, 'Sign in'),
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
                        context.go('/signup');
                      },
                child: const Text("Don't have an account? Sign up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
