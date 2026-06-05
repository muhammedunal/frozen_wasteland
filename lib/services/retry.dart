import 'dart:async';

/// Generic retry helper with exponential backoff.
///
/// Retries [action] up to [maxAttempts] times while [retryIf] returns true for
/// the thrown error. Backoff defaults to 200ms * 2^(attempt-1); pass
/// [baseDelay] = Duration.zero in tests to avoid real waiting.
Future<T> retry<T>(
  Future<T> Function() action, {
  int maxAttempts = 3,
  bool Function(Object error)? retryIf,
  Duration baseDelay = const Duration(milliseconds: 200),
  Future<void> Function(Duration)? sleep,
}) async {
  var attempt = 0;
  while (true) {
    attempt++;
    try {
      return await action();
    } catch (e) {
      final canRetry = attempt < maxAttempts && (retryIf?.call(e) ?? true);
      if (!canRetry) rethrow;
      final delay = baseDelay * (1 << (attempt - 1));
      if (delay > Duration.zero) {
        await (sleep?.call(delay) ?? Future<void>.delayed(delay));
      }
    }
  }
}
