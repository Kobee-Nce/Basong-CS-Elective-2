import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'cart_provider.dart';
import 'service_providers.dart';

/// Sign in, sign out, token refresh and the Google redirect.
/// Keeps the UI in sync with the Supabase session.
final authStateChangesProvider = StreamProvider<AuthState>(
  (ref) => ref.watch(authServiceProvider).authStateChanges(),
);

/// The signed-in user's id, or null when signed out.
/// A String, so token refreshes (same id) don't trigger rebuilds.
final currentUserIdProvider = Provider<String?>((ref) {
  ref.watch(authStateChangesProvider);
  return ref.watch(authServiceProvider).currentUser?.id;
});

/// Loading / error state of the login and sign-up forms.
class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> signIn({required String email, required String password}) {
    return _run(
      () => ref
          .read(authServiceProvider)
          .signInWithEmail(email: email, password: password),
    );
  }

  /// Returns true when signed in right away, false when the email still
  /// needs confirming (or the sign-up failed — see [state]).
  Future<bool> signUp({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
  }) async {
    var signedIn = false;
    await _run(() async {
      signedIn = await ref.read(authServiceProvider).signUpWithEmail(
            email: email,
            password: password,
            firstname: firstname,
            lastname: lastname,
          );
    });
    return signedIn;
  }

  Future<void> signInWithGoogle() =>
      _run(() => ref.read(authServiceProvider).signInWithGoogle());

  /// Empties the cart, then ends the session. The router sends the user
  /// back to the login page.
  Future<void> signOut() async {
    ref.read(cartProvider.notifier).clear();
    await _run(() => ref.read(authServiceProvider).signOut());
  }

  void clearError() => state = const AsyncData(null);

  Future<void> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(action);
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);
