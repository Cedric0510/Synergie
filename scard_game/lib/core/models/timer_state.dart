import 'package:freezed_annotation/freezed_annotation.dart';

part 'timer_state.freezed.dart';

/// États possibles du minuteur
enum TimerStatus {
  idle, // Non démarré
  running, // En cours
  paused, // En pause
  finished, // Terminé
}

/// État du minuteur de jeu
@freezed
class TimerState with _$TimerState {
  const factory TimerState({
    @Default(TimerStatus.idle) TimerStatus status,
    @Default(0) int remainingSeconds, // Temps restant en secondes
    @Default(0) int totalSeconds, // Durée totale configurée
  }) = _TimerState;

  const TimerState._();

  /// Indique si le timer est actif (running ou paused)
  bool get isActive => status == TimerStatus.running || status == TimerStatus.paused;

  /// Formatte le temps restant en MM:SS
  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Progression en pourcentage (0.0 à 1.0)
  double get progress {
    if (totalSeconds == 0) return 0.0;
    return (totalSeconds - remainingSeconds) / totalSeconds;
  }
}
