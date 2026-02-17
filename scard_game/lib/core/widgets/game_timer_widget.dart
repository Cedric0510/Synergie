import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/game_timer_notifier.dart';
import '../models/timer_state.dart';

/// Widget du minuteur de jeu avec design crystal
class GameTimerWidget extends ConsumerWidget {
  final bool isSmallMobile;

  const GameTimerWidget({
    super.key,
    this.isSmallMobile = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(gameTimerProvider);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showTimerDialog(context, ref, timerState),
        borderRadius: BorderRadius.circular(isSmallMobile ? 16 : 20),
        child: Container(
          width: isSmallMobile ? 32 : 40,
          height: isSmallMobile ? 32 : 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: timerState.isActive
                  ? [
                      const Color(0xFF6DD5FA).withValues(alpha: 0.4),
                      const Color(0xFF6DD5FA).withValues(alpha: 0.25),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.25),
                      Colors.white.withValues(alpha: 0.15),
                    ],
            ),
            border: Border.all(
              color: timerState.isActive
                  ? const Color(0xFF6DD5FA).withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: timerState.isActive
                    ? const Color(0xFF6DD5FA).withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              timerState.status == TimerStatus.running
                  ? Icons.timer
                  : Icons.timer_outlined,
              color: timerState.isActive
                  ? const Color(0xFF6DD5FA)
                  : Colors.white,
              size: isSmallMobile ? 16 : 20,
            ),
          ),
        ),
      ),
    );
  }

  /// Affiche le dialog du minuteur
  void _showTimerDialog(
    BuildContext context,
    WidgetRef ref,
    TimerState timerState,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _TimerDialog(timerState: timerState),
    );
  }
}

/// Dialog du minuteur avec contrôles
class _TimerDialog extends ConsumerWidget {
  final TimerState timerState;

  const _TimerDialog({required this.timerState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentState = ref.watch(gameTimerProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2d4263), Color(0xFF1a2332)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF6DD5FA).withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6DD5FA).withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Titre
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Minuteur',
                  style: TextStyle(
                    color: Color(0xFF6DD5FA),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Affichage du temps si actif
            if (currentState.isActive || currentState.status == TimerStatus.finished)
              _buildTimeDisplay(currentState)
            else
              _buildPresetButtons(ref, context),

            const SizedBox(height: 16),

            // Contrôles si timer actif
            if (currentState.isActive || currentState.status == TimerStatus.finished)
              _buildControls(ref, currentState, context),
          ],
        ),
      ),
    );
  }

  /// Affichage du temps restant avec barre de progression
  Widget _buildTimeDisplay(TimerState state) {
    return Column(
      children: [
        // Temps restant
        Text(
          state.formattedTime,
          style: TextStyle(
            color: state.status == TimerStatus.finished
                ? const Color(0xFFFF6B6B)
                : const Color(0xFF6DD5FA),
            fontSize: 48,
            fontWeight: FontWeight.bold,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),

        const SizedBox(height: 16),

        // Barre de progression
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: state.progress,
            minHeight: 8,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(
              state.status == TimerStatus.finished
                  ? const Color(0xFFFF6B6B)
                  : const Color(0xFF6DD5FA),
            ),
          ),
        ),

        if (state.status == TimerStatus.finished)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Terminé !',
              style: TextStyle(
                color: const Color(0xFFFF6B6B),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  /// Boutons de présélection des durées
  Widget _buildPresetButtons(WidgetRef ref, BuildContext context) {
    final presets = <num>[0.5, 1, 2, 3, 4, 5];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: presets
          .map((minutes) => _buildPresetButton(minutes, ref, context))
          .toList(),
    );
  }

  /// Bouton de présélection individuel
  Widget _buildPresetButton(num minutes, WidgetRef ref, BuildContext context) {
    final label = minutes < 1 ? '30s' : '${minutes.toInt()} min';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ref.read(gameTimerProvider.notifier).start(minutes);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF6DD5FA).withValues(alpha: 0.3),
                const Color(0xFF6DD5FA).withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF6DD5FA).withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6DD5FA),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// Contrôles Play/Pause/Stop/Restart
  Widget _buildControls(WidgetRef ref, TimerState state, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Pause/Resume
        if (state.status != TimerStatus.finished)
          _buildControlButton(
            icon: state.status == TimerStatus.running
                ? Icons.pause
                : Icons.play_arrow,
            onTap: () {
              if (state.status == TimerStatus.running) {
                ref.read(gameTimerProvider.notifier).pause();
              } else {
                ref.read(gameTimerProvider.notifier).resume();
              }
            },
          ),

        // Restart
        _buildControlButton(
          icon: Icons.refresh,
          onTap: () => ref.read(gameTimerProvider.notifier).restart(),
        ),

        // Stop
        _buildControlButton(
          icon: Icons.stop,
          color: const Color(0xFFFF6B6B),
          onTap: () {
            ref.read(gameTimerProvider.notifier).stop();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  /// Bouton de contrôle individuel
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = const Color(0xFF6DD5FA),
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.3),
                color.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }
}
