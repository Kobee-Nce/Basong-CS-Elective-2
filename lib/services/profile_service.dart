import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_exception.dart';
import '../models/profile.dart';
import 'supabase_errors.dart';

/// Reads and updates rows of `profiles`.
class ProfileService {
  ProfileService(this._client);

  final SupabaseClient _client;

  static const _columns = '*, roles(role)';

  Future<Profile> fetchProfile(String userId) {
    return guard(() async {
      final row = await _client
          .from('profiles')
          .select(_columns)
          .eq('id', userId)
          .maybeSingle();

      if (row == null) {
        throw const AppException(
          'Your profile was not found. Make sure the handle_new_user '
          'trigger is set up in Supabase, then sign up again.',
          AppErrorKind.notFound,
        );
      }
      return Profile.fromMap(row);
    });
  }

  /// Customers may change their names only (never the role — the
  /// database rejects that through column privileges).
  Future<Profile> updateName({
    required String userId,
    required String firstname,
    required String lastname,
  }) {
    return guard(() async {
      final row = await _client
          .from('profiles')
          .update({'firstname': firstname, 'lastname': lastname})
          .eq('id', userId)
          .select(_columns)
          .maybeSingle();

      if (row == null) {
        throw const AppException(
          "Your profile wasn't updated. You may not have permission.",
          AppErrorKind.permissionDenied,
        );
      }
      return Profile.fromMap(row);
    });
  }

  /// Name + email for each user id (admin only — RLS hides other
  /// customers' profiles from customers).
  Future<Map<String, Map<String, dynamic>>> fetchContactInfo(
    List<String> userIds,
  ) {
    return guard(() async {
      if (userIds.isEmpty) return {};
      final rows = await _client
          .from('profiles')
          .select('id, email, firstname, lastname')
          .inFilter('id', userIds);
      return {for (final row in rows) row['id'] as String: row};
    });
  }
}
