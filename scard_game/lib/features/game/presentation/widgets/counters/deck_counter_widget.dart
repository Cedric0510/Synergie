import 'package:flutter/material.dart';

/// Widget affichant le compteur de cartes restantes dans le deck
/// Change de couleur selon le nombre de cartes (bleu > 30, orange > 15, rouge <= 15)
class DeckCounterWidget extends StatelessWidget {
  final int remainingCards;

  const DeckCounterWidget({super.key, required this.remainingCards});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 14,
        vertical: isMobile ? 6 : 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _getCounterColor().withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Brillance en haut
          Positioned(
            top: -6,
            left: -8,
            right: -8,
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.4),
                    Colors.white.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.style,
                color: Colors.white,
                size: isMobile ? 16 : 18,
                shadows: const [
                  Shadow(
                    color: Colors.black54,
                    offset: Offset(0, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Text(
                '$remainingCards carte${remainingCards > 1 ? 's' : ''}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 12 : 14,
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
