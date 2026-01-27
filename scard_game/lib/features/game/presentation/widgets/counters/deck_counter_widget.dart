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

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallMobile ? 6 : (isMobile ? 10 : 14),
        vertical: isSmallMobile ? 4 : (isMobile ? 6 : 8),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmallMobile ? 12 : 16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getCounterColor().withOpacity(0.3),
            _getCounterColor().withOpacity(0.2),
          ],
        ),
        border: Border.all(
          color: _getCounterColor().withOpacity(0.6),
          width: isSmallMobile ? 1.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _getCounterColor().withOpacity(0.3),
            blurRadius: isSmallMobile ? 4 : 8,
            spreadRadius: isSmallMobile ? 0 : 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.style,
            color: Colors.white,
            size: isSmallMobile ? 12 : (isMobile ? 16 : 18),
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
            isSmallMobile
                ? '$remainingCards'
                : '$remainingCards carte${remainingCards > 1 ? 's' : ''}',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallMobile ? 9 : (isMobile ? 12 : 14),
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
