import 'package:flutter/material.dart';

/// Barre de tension affichant le pourcentage et la progression
class TensionBarWidget extends StatelessWidget {
  final double tension;

  const TensionBarWidget({super.key, required this.tension});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tension',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              '${tension.toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: tension / 100,
            minHeight: 8,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getTensionColor(tension),
            ),
          ),
        ),
      ],
    );
  }

  Color _getTensionColor(double tension) {
    if (tension < 25) return Colors.white;
    if (tension < 50) return Colors.blue;
    if (tension < 75) return Colors.yellow;
    return Colors.red;
  }
}
