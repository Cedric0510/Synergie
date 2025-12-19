import 'package:flutter/material.dart';

/// Barre de progression de tension (0-100%)
class TensionBar extends StatelessWidget {
  final double tension; // 0.0 à 100.0
  final double height;
  final bool showPercentage;

  const TensionBar({
    super.key,
    required this.tension,
    this.height = 24,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final clampedTension = tension.clamp(0.0, 100.0);
    final progress = clampedTension / 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showPercentage)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'Tension: ${clampedTension.toInt()}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                // Fond
                Container(color: Colors.white.withOpacity(0.3)),
                // Progression avec gradient
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getGradientColors(clampedTension),
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
                // Brillance
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Color> _getGradientColors(double tension) {
    if (tension < 25) {
      // 0-25% : Blanc → Bleu clair
      return [Colors.white, const Color(0xFF3498DB)];
    } else if (tension < 50) {
      // 25-50% : Bleu → Jaune
      return [const Color(0xFF3498DB), const Color(0xFFF39C12)];
    } else if (tension < 75) {
      // 50-75% : Jaune → Orange
      return [const Color(0xFFF39C12), const Color(0xFFFF8C00)];
    } else {
      // 75-100% : Orange → Rouge
      return [const Color(0xFFFF8C00), const Color(0xFFE74C3C)];
    }
  }
}
