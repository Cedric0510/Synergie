import 'package:flutter/material.dart';

/// Widget affichant le compteur de cartes restantes dans le deck
/// Change de couleur selon le nombre de cartes (bleu > 30, orange > 15, rouge <= 15)
class DeckCounterWidget extends StatelessWidget {
  final int remainingCards;

  const DeckCounterWidget({super.key, required this.remainingCards});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isSmallMobile = screenWidth < 380;
    final countFontSize = isSmallMobile ? 11.0 : (isMobile ? 14.0 : 16.0);
    final labelFontSize = isSmallMobile ? 0.0 : (isMobile ? 9.0 : 10.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallMobile ? 7 : (isMobile ? 10 : 12),
        vertical: isSmallMobile ? 5 : (isMobile ? 6 : 7),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmallMobile ? 12 : 16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getCounterColor().withValues(alpha: 0.22),
            _getCounterColor().withValues(alpha: 0.14),
          ],
        ),
        border: Border.all(
          color: _getCounterColor().withValues(alpha: 0.45),
          width: isSmallMobile ? 1.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _getCounterColor().withValues(alpha: 0.18),
            blurRadius: isSmallMobile ? 3 : 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.layers_outlined,
            color: Colors.white,
            size: isSmallMobile ? 12 : (isMobile ? 15 : 17),
            shadows: const [
              Shadow(
                color: Colors.black54,
                offset: Offset(0, 1),
                blurRadius: 3,
              ),
            ],
          ),
          SizedBox(width: isSmallMobile ? 3 : (isMobile ? 6 : 8)),
          Text(
            '$remainingCards',
            style: TextStyle(
              color: Colors.white,
              fontSize: countFontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              shadows: const [
                Shadow(
                  color: Colors.black54,
                  offset: Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
          if (!isSmallMobile) ...[
            SizedBox(width: isMobile ? 5 : 6),
            Text(
              'DECK',
              style: TextStyle(
                color: Colors.white70,
                fontSize: labelFontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Couleur selon le nombre de cartes restantes
  Color _getCounterColor() {
    if (remainingCards > 30) return Colors.blue.shade700;
    if (remainingCards > 15) return Colors.orange.shade700;
    return Colors.red.shade700;
  }
}
