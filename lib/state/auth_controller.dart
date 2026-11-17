import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

/// Signed-in user + sign-in/sign-up/sign-out actions, backed by Supabase Auth.
///
/// Same pattern as CartController / ProductsController. The router listens
/// to this controller, so signing in or out moves the user between the
/// login screen and the shop automatically.
class AuthController extends ChangeNotifier {
  static final AuthController instance = AuthController._();

  AuthController._();

  /// Where GitHub (through Supabase) sends the user back after signing in.
  /// The same scheme is registered in macos/ios Info.plist and
  /// AndroidManifest.xml, and must be added in Supabase under
  /// Authentication → URL Configuration → Redirect URLs.
  static const String oauthRedirect =
      'io.supabase.gamecreditsshop://login-callback/';

  StreamSubscription<AuthState>? _subscription;

  bool isLoading = false;
  String? error;

  /// Shown after sign-up when Supabase still needs the email confirmed.
  String? info;

  GoTrueClient get _auth => Supabase.instance.client.auth;

  User? get user =>
      SupabaseConfig.isConfigured ? _auth.currentUser : null;

  bool get isSignedIn => user != null;

  /// Call once at startup (after Supabase.initialize).
  void init() {
    if (!SupabaseConfig.isConfigured || _subscription != null) return;

    // Fires on sign in, sign out, token refresh, and when the app is
    // reopened from the GitHub redirect link.
    _subscription = _auth.onAuthStateChange.listen(
      (state) {
        if (state.event == AuthChangeEvent.signedIn) {
          isLoading = false;
          error = null;
          info = null;
        }
        notifyListeners();
      },
      onError: (Object e) {
        isLoading = false;
        error = _describe(e);
        notifyListeners();
      },
    );
  }

  Future<void> signInWithEmail(String email, String password) {
    return _run(() async {
      await _auth.signInWithPassword(email: email, password: password);
    });
  }

  Future<void> signUpWithEmail(String email, String password) {
    return _run(() async {
      final response = await _auth.signUp(email: email, password: password);

      // "Confirm email" is on by default in Supabase: the account exists
      // but there's no session until the link in the email is clicked.
      if (response.session == null) {
        info = 'Account created! Check $email for a confirmation link, '
            'then sign in.';
      }
    });
  }

  /// Opens GitHub in the browser. The result arrives later through
  /// onAuthStateChange when the redirect link reopens the app.
  Future<void> signInWithGitHub() {
    return _run(() async {
      await _auth.signInWithOAuth(
        OAuthProvider.github,
        // On web, Supabase returns to the page that started the sign-in.
        redirectTo: kIsWeb ? null : oauthRedirect,
        authScreenLaunchMode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );
    });
  }

  Future<void> signOut() => _run(_auth.signOut);

  void clearMessages() {
    error = null;
    info = null;
    notifyListeners();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (!SupabaseConfig.isConfigured) {
      error = 'Supabase is not configured yet. Add your project URL and '
          'anon key in lib/config/supabase_config.dart.';
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    info = null;
    notifyListeners();

    try {
      await action();
    } catch (e) {
      error = _describe(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _describe(Object e) {
    if (e is AuthException) return e.message;
    return 'Something went wrong. Check your internet connection.\n($e)';
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
