import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/services/game_timer_notifier.dart';
import '../../../../../core/models/timer_state.dart';

/// Dialog affichant le décompte du timer avec un visuel central
class TimerCountdownDialog extends ConsumerWidget {
  const TimerCountdownDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(gameTimerProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 350),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2d4263), Color(0xFF1a2332)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF8E44AD).withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8E44AD).withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Titre
            const Text(
              'Décompte en cours',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            
            // Indicateur circulaire avec temps restant
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Cercle de progression
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: timerState.progress,
                      strokeWidth: 12,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getTimerColor(timerState),
                      ),
                    ),
                  ),
                  
                  // Temps restant
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timerState.formattedTime,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFeatures: [
                            FontFeature.tabularFigures(),
                          ],
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
            
            const SizedBox(height: 32),
            
            // Boutons de contrôle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pause/Resume
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
                
                const SizedBox(width: 16),
                
                // Arrêter
                _buildControlButton(
                  icon: Icons.stop,
                  label: 'Arrêter',
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
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? const Color(0xFF8E44AD),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
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
      return const Color(0xFF8E44AD); // Violet
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
        return 'Terminé !';
      case TimerStatus.idle:
        return '';
    }
  }
}
