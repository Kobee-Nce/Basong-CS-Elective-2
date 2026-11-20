import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_exception.dart';

/// Renders every state of an async provider: loading, error (with a
/// permission-denied variant), empty, and data.
class AsyncValueView<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;

  /// Optional: return true when [data] has nothing to show.
  final bool Function(T data)? isEmpty;
  final Widget? empty;

  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
    this.isEmpty,
    this.empty,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const LoadingView(),
      error: (error, _) => ErrorView(error: error, onRetry: onRetry),
      data: (d) {
        if (isEmpty != null && isEmpty!(d) && empty != null) return empty!;
        return data(d);
      },
    );
  }
}

class LoadingView extends StatelessWidget {
  final String? message;

  const LoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          if (message != null) ...[
            const SizedBox(height: 14),
            Text(message!, style: const TextStyle(color: Colors.white, fontSize: 17)),
          ],
        ],
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  const ErrorView({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final app = error is AppException ? error as AppException : null;
    final denied = app?.isPermissionDenied ?? false;

    return MessageView(
      icon: denied
          ? Icons.lock_outline_rounded
          : app?.kind == AppErrorKind.network
              ? Icons.wifi_off_rounded
              : Icons.cloud_off_rounded,
      title: denied ? 'Permission denied' : 'Something went wrong',
      message: app?.message ?? error.toString(),
      actionLabel: onRetry == null || denied ? null : 'Retry',
      onAction: onRetry,
    );
  }
}

/// Centered icon + text (+ optional button). Used for empty states too.
class MessageView extends StatelessWidget {
  final IconData icon;
  final String? title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const MessageView({
    super.key,
    required this.icon,
    this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 60),
            if (title != null) ...[
              const SizedBox(height: 10),
              Text(
                title!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 17),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
