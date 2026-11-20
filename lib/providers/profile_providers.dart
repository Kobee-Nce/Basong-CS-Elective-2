import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/profile.dart';
import 'auth_providers.dart';
import 'service_providers.dart';

/// The signed-in user's profile (with role). Null when signed out.
/// The router uses it to decide between the admin and customer screens.
final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  final service = ref.watch(profileServiceProvider);
  return service.fetchProfile(userId);
});

/// Saving the customer's first/last name.
class ProfileController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> updateName({
    required String firstname,
    required String lastname,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return false;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(profileServiceProvider).updateName(
            userId: userId,
            firstname: firstname,
            lastname: lastname,
          );
    });

    if (state.hasError) return false;
    ref.invalidate(currentProfileProvider);
    return true;
  }
}

final profileControllerProvider =
    NotifierProvider<ProfileController, AsyncValue<void>>(
  ProfileController.new,
);
