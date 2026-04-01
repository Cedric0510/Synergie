import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/models/timer_state.dart';
import '../../../../../core/services/game_timer_notifier.dart';

/// Dialog affichant le décompte du timer avec un visuel central.
class TimerCountdownDialog extends ConsumerWidget {
  const TimerCountdownDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(gameTimerProvider);
    const accent = Color(0xFF6DD5FA);
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final ringSize = isSmallScreen ? 168.0 : 200.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 360,
          maxHeight: MediaQuery.of(context).size.height * 0.84,
        ),
        padding: EdgeInsets.all(isSmallScreen ? 20 : 28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2D4263), Color(0xFF1A2332)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accent.withValues(alpha: 0.45), width: 2),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.28),
              blurRadius: 24,
              spreadRadius: 0,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Decompte en cours',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: isSmallScreen ? 20 : 28),
              SizedBox(
                width: ringSize,
                height: ringSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: ringSize,
                      height: ringSize,
                      child: CircularProgressIndicator(
                        value: timerState.progress,
                        strokeWidth: isSmallScreen ? 10 : 12,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getTimerColor(timerState),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timerState.formattedTime,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 40 : 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getStatusText(timerState.status),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: isSmallScreen ? 20 : 28),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  if (timerState.status == TimerStatus.running)
                    _buildControlButton(
                      icon: Icons.pause,
                      label: 'Pause',
                      onPressed: () {
                        ref.read(gameTimerProvider.notifier).pause();
                      },
                    )
                  else if (timerState.status == TimerStatus.paused)
                    _buildControlButton(
                      icon: Icons.play_arrow,
                      label: 'Reprendre',
                      onPressed: () {
                        ref.read(gameTimerProvider.notifier).resume();
                      },
                    ),
                  _buildControlButton(
                    icon: Icons.stop,
                    label: 'Arreter',
                    onPressed: () {
                      ref.read(gameTimerProvider.notifier).stop();
                      Navigator.of(context).pop();
                    },
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    final buttonColor = color ?? const Color(0xFF6DD5FA);

    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      style: TextButton.styleFrom(
        backgroundColor: buttonColor.withValues(alpha: 0.22),
        foregroundColor: buttonColor,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: buttonColor.withValues(alpha: 0.45)),
        ),
      ),
    );
  }

  Color _getTimerColor(TimerState state) {
    if (state.status == TimerStatus.paused) {
      return Colors.orange;
    }

    final progress = state.progress;
    if (progress > 0.5) {
      return const Color(0xFF6DD5FA);
    } else if (progress > 0.2) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getStatusText(TimerStatus status) {
    switch (status) {
      case TimerStatus.running:
        return 'En cours...';
      case TimerStatus.paused:
        return 'En pause';
      case TimerStatus.finished:
        return 'Termine';
      case TimerStatus.idle:
        return '';
    }
  }
}
