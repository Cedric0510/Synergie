import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Niveaux de log disponibles
enum LogLevel { debug, info, warning, error }

/// Service de logging centralisé
///
/// Remplace les debugPrint() par un système structuré qui:
/// - N'affiche les logs qu'en mode debug
/// - Permet de filtrer par niveau
/// - Ajoute un préfixe avec timestamp et tag
///
/// Usage:
/// ```dart
/// final logger = ref.read(loggerServiceProvider);
/// logger.debug('CardService', 'Chargement des cartes...');
/// logger.info('GameScreen', 'Partie démarrée');
/// logger.warning('Firebase', 'Connexion lente');
/// logger.error('Auth', 'Échec de connexion', error);
/// ```
class LoggerService {
  /// Niveau minimum de log à afficher
  LogLevel minLevel = LogLevel.debug;

  /// Active/désactive tous les logs
  bool enabled = true;

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
  }

  void _log(LogLevel level, String tag, String message) {
    if (!enabled || !kDebugMode) return;
    if (level.index < minLevel.index) return;

    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    final prefix = _levelPrefix(level);

    debugPrint('$prefix [$timestamp] $tag: $message');
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
