import 'package:flutter/material.dart';

/// Barre de tension affichant le pourcentage et la progression
class TensionBarWidget extends StatelessWidget {
  final double tension;
  final bool compact;

  const TensionBarWidget({
    super.key,
    required this.tension,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallMobile = screenWidth < 380;
    final labelSize = compact ? (isSmallMobile ? 9.0 : 10.0) : 12.0;
    final valueSize = compact ? (isSmallMobile ? 9.0 : 10.0) : 12.0;
    final barHeight = compact ? (isSmallMobile ? 6.0 : 7.0) : 8.0;
    final spacing = compact ? 3.0 : 4.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tension',
              style: TextStyle(color: Colors.white70, fontSize: labelSize),
            ),
            Text(
              '${tension.toInt()}%',
              style: TextStyle(
                color: Colors.white,
                fontSize: valueSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: tension / 100,
            minHeight: barHeight,
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
