import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/gradient_scaffold.dart';

/// Shared layout for the login and sign-up pages.
class AuthLayout extends StatelessWidget {
  final String subtitle;
  final Widget child;

  const AuthLayout({super.key, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      showAppBar: false,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sports_esports_rounded, color: Colors.white, size: 64),
                const SizedBox(height: 8),
                const Text(
                  'Game Credits Shop',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Inline error / info box inside the auth card.
class AuthNotice extends StatelessWidget {
  final String text;
  final bool isError;

  const AuthNotice({super.key, required this.text, this.isError = true});

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppTheme.valorantRed : AppTheme.success;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: .5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.mark_email_read_outlined,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: color))),
        ],
      ),
    );
  }
}

/// "Continue with Google".
class GoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const GoogleButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        side: const BorderSide(color: Color(0xFFDADCE0)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'G',
            style: TextStyle(
              color: Color(0xFF4285F4),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(width: 12),
          Text('Continue with Google', style: TextStyle(fontSize: 17)),
        ],
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Divider()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('or'),
          ),
          Expanded(child: Divider()),
        ],
      ),
    );
  }
}

String? validateEmail(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Enter your email';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
    return 'Enter a valid email';
  }
  return null;
}

Widget buttonChild(bool busy, String label) => busy
    ? const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
      )
    : Text(label, style: const TextStyle(fontSize: 18));
