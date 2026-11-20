import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_errors.dart';

/// Supabase Auth: email/password and Google.
class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;

  /// Where Google (through Supabase) sends the user back on mobile/desktop.
  /// Registered in AndroidManifest.xml and the iOS/macOS Info.plist, and
  /// must be listed in Supabase → Authentication → URL Configuration.
  static const String oauthRedirect =
      'io.supabase.gamecreditsshop://login-callback/';

  GoTrueClient get _auth => _client.auth;

  /// Fires on sign in, sign out, token refresh and the OAuth redirect.
  Stream<AuthState> authStateChanges() => _auth.onAuthStateChange;

  User? get currentUser => _auth.currentUser;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) {
    return guard(() async {
      await _auth.signInWithPassword(email: email, password: password);
    });
  }

  /// Returns true when the user is signed in right away, false when
  /// Supabase still needs the email confirmed first.
  ///
  /// firstname/lastname go into raw_user_meta_data, where the
  /// handle_new_user() trigger reads them to create the profile.
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
  }) {
    return guard(() async {
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: {'firstname': firstname, 'lastname': lastname},
      );
      return response.session != null;
    });
  }

  /// Opens Google in the browser. The session arrives later through
  /// [authStateChanges] when the redirect brings the user back.
  Future<void> signInWithGoogle() {
    return guard(() async {
      await _auth.signInWithOAuth(
        OAuthProvider.google,
        // On web, Supabase returns to the page that started the sign-in.
        redirectTo: kIsWeb ? null : oauthRedirect,
        authScreenLaunchMode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );
    });
  }

  Future<void> signOut() => guard(() => _auth.signOut());
}
