import 'package:flutter/material.dart';
import '../../../domain/models/game_session.dart';

/// Widget affichant le compteur Ultima (3 tours max)
/// Indique qui possède Ultima et le nombre de tours restants
class UltimaCounterWidget extends StatelessWidget {
  final GameSession session;
  final String playerId;

  const UltimaCounterWidget({
    super.key,
    required this.session,
    required this.playerId,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isSmallMobile = screenWidth < 380;
    final isMyUltima = session.ultimaOwnerId == playerId;
    final turnCount = session.ultimaTurnCount;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallMobile ? 6 : (isMobile ? 12 : 16),
        vertical: isSmallMobile ? 4 : (isMobile ? 8 : 10),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmallMobile ? 12 : 20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getCounterColor(turnCount).withOpacity(0.4),
            _getCounterColor(turnCount).withOpacity(0.25),
          ],
        ),
        border: Border.all(
          color: _getCounterColor(turnCount).withOpacity(0.8),
          width: isSmallMobile ? 1.5 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getCounterColor(turnCount).withOpacity(0.5),
            blurRadius: isSmallMobile ? 6 : 12,
            spreadRadius: isSmallMobile ? 1 : 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: isSmallMobile ? 14 : (isMobile ? 20 : 24),
            shadows: const [
              Shadow(
                color: Colors.black54,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          SizedBox(width: isSmallMobile ? 4 : (isMobile ? 8 : 12)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isSmallMobile
                    ? (isMyUltima ? 'ULTIMA' : 'ADV.')
                    : 'ULTIMA ${isMyUltima ? "(VOUS)" : "(ADVERSAIRE)"}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallMobile ? 8 : (isMobile ? 11 : 13),
                  fontWeight: FontWeight.bold,
                  letterSpacing: isSmallMobile ? 0.5 : 1.2,
                  shadows: const [
                    Shadow(
                      color: Colors.black54,
                      offset: Offset(0, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
              SizedBox(height: isSmallMobile ? 1 : 2),
              Text(
                isSmallMobile ? '$turnCount/3' : 'Tour $turnCount/3',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: isSmallMobile ? 10 : (isMobile ? 13 : 15),
                  fontWeight: FontWeight.w900,
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

  /// Couleur selon le compteur de tours
  Color _getCounterColor(int turnCount) {
    if (turnCount == 0) return Colors.purple;
    if (turnCount == 1) return Colors.orange;
    if (turnCount == 2) return Colors.red;
    return Colors.red;
  }
}
