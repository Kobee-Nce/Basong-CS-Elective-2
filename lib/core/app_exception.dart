/// What kind of failure happened, so the UI can pick the right icon
/// and message (e.g. a lock icon for "permission denied").
enum AppErrorKind { permissionDenied, notFound, conflict, validation, auth, network, unknown }

/// The only error type that leaves the service layer.
/// Services translate Supabase / Postgres / network errors into this.
class AppException implements Exception {
  final String message;
  final AppErrorKind kind;

  const AppException(this.message, [this.kind = AppErrorKind.unknown]);

  bool get isPermissionDenied => kind == AppErrorKind.permissionDenied;

  @override
  String toString() => message;
}

/// Thrown when a requested page is past the last row (e.g. after a delete).
class PageOutOfRangeException extends AppException {
  const PageOutOfRangeException()
      : super('That page no longer exists.', AppErrorKind.notFound);
}
