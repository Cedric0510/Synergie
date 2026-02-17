import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/timer_state.dart';
import 'audio_service.dart';

/// Provider du minuteur de jeu
final gameTimerProvider =
    StateNotifierProvider<GameTimerNotifier, TimerState>((ref) {
  return GameTimerNotifier();
});

/// Notifier gérant l'état du minuteur
class GameTimerNotifier extends StateNotifier<TimerState> {
  GameTimerNotifier() : super(const TimerState());

  Timer? _timer;

  /// Lance le timer avec une durée en minutes (supporte les décimales: 0.5 = 30s)
  void start(num minutes) {
    _cancelTimer();

    final totalSeconds = (minutes * 60).round();
    state = TimerState(
      status: TimerStatus.running,
      remainingSeconds: totalSeconds,
      totalSeconds: totalSeconds,
    );

    _startCountdown();
  }

  /// Met le timer en pause
  void pause() {
    if (state.status != TimerStatus.running) return;
    _cancelTimer();
    state = state.copyWith(status: TimerStatus.paused);
  }

  /// Reprend le timer après une pause
  void resume() {
    if (state.status != TimerStatus.paused) return;
    state = state.copyWith(status: TimerStatus.running);
    _startCountdown();
  }

  /// Arrête et réinitialise le timer
  void stop() {
    _cancelTimer();
    state = const TimerState();
  }

  /// Relance le timer avec la même durée
  void restart() {
    if (state.totalSeconds == 0) return;
    final minutes = state.totalSeconds ~/ 60;
    start(minutes);
  }

  /// Démarre le compte à rebours interne
  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _cancelTimer();
        state = state.copyWith(status: TimerStatus.finished);
        // Joue le son de fin
        AudioService.playTimerFinished();
      }
    });
  }

  /// Annule le timer interne
  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}
