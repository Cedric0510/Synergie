import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Niveaux de log disponibles
enum LogLevel { debug, info, warning, error }

/// Callback type for external error reporting (Crashlytics, Sentry, etc.)
typedef ErrorReporter =
    void Function(
      String tag,
      String message,
      Object? error,
      StackTrace? stackTrace,
    );

/// Service de logging centralisé
///
/// - Debug mode: all levels printed to console
/// - Release mode: warning & error logged via dart:developer
/// - Optional [onError] callback for crash reporting integration
class LoggerService {
  /// Niveau minimum de log à afficher
  LogLevel minLevel = LogLevel.debug;

  /// Active/désactive tous les logs
  bool enabled = true;

  /// Optional callback for external crash reporting.
  /// Set this to forward errors to Crashlytics/Sentry.
  ErrorReporter? onError;

  /// Log de niveau debug (développement uniquement)
  void debug(String tag, String message) {
    _log(LogLevel.debug, tag, message);
  }

  /// Log de niveau info
  void info(String tag, String message) {
    _log(LogLevel.info, tag, message);
  }

  /// Log de niveau warning
  void warning(String tag, String message) {
    _log(LogLevel.warning, tag, message);
  }

  /// Log de niveau error avec exception optionnelle
  void error(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _log(LogLevel.error, tag, message);
    if (error != null && kDebugMode) {
      debugPrint('  └─ Error: $error');
      if (stackTrace != null) {
        debugPrint('  └─ Stack: $stackTrace');
      }
    }
    // Forward to external reporter in all modes
    onError?.call(tag, message, error, stackTrace);
  }

  void _log(LogLevel level, String tag, String message) {
    if (!enabled) return;
    if (level.index < minLevel.index) return;

    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    final prefix = _levelPrefix(level);
    final formatted = '$prefix [$timestamp] $tag: $message';

    if (kDebugMode) {
      debugPrint(formatted);
    } else if (level.index >= LogLevel.warning.index) {
      // In release mode, log warnings and errors via dart:developer
      developer.log(
        formatted,
        name: tag,
        level: level == LogLevel.error ? 1000 : 900,
      );
    }
  }

  String _levelPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
    }
  }
}

/// Provider pour le service de logging
final loggerServiceProvider = Provider<LoggerService>((ref) {
  return LoggerService();
});
