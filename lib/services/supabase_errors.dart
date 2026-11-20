import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_exception.dart';

/// Runs a Supabase call and turns any failure into an [AppException]
/// with a message that is safe to show to the user.
Future<T> guard<T>(Future<T> Function() body) async {
  try {
    return await body();
  } catch (e) {
    throw mapError(e);
  }
}

AppException mapError(Object error) {
  if (error is AppException) return error;

  if (error is AuthException) {
    return AppException(error.message, AppErrorKind.auth);
  }

  if (error is PostgrestException) {
    final message = error.message;
    switch (error.code) {
      // insufficient_privilege: RLS violation, missing column grant,
      // or a 42501 raised on purpose by place_order().
      case '42501':
        final generic = message.contains('row-level security') ||
            message.startsWith('permission denied');
        return AppException(
          generic ? "You don't have permission to do that." : message,
          AppErrorKind.permissionDenied,
        );
      case '23503':
        return const AppException(
          'This item is still in use. A category with products cannot be '
          'deleted — move or delete its products first.',
          AppErrorKind.conflict,
        );
      case '23505':
        return const AppException(
          'That name is already taken.',
          AppErrorKind.conflict,
        );
      case '23514':
        return const AppException(
          'Some values are not allowed (e.g. a negative price or stock).',
          AppErrorKind.validation,
        );
      case 'PGRST116':
        return const AppException('Not found.', AppErrorKind.notFound);
      case 'PGRST103':
        return const PageOutOfRangeException();
      // Exceptions raised by our own SQL (e.g. "Not enough stock ...").
      case 'P0001':
        return AppException(message, AppErrorKind.validation);
    }
    return AppException(message);
  }

  if (error is StorageException) {
    final status = error.statusCode;
    if (status == '403' || status == '401') {
      return const AppException(
        "You don't have permission to upload images.",
        AppErrorKind.permissionDenied,
      );
    }
    return AppException('Image upload failed: ${error.message}');
  }

  final text = error.toString();
  if (text.contains('SocketException') ||
      text.contains('ClientException') ||
      text.contains('Failed host lookup') ||
      text.contains('XMLHttpRequest')) {
    return const AppException(
      'Could not reach the server. Check your internet connection.',
      AppErrorKind.network,
    );
  }

  return AppException('Something went wrong. ($text)');
}
