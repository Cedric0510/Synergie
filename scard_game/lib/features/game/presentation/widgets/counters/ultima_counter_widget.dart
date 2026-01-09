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
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isMyUltima = session.ultimaOwnerId == playerId;
    final turnCount = session.ultimaTurnCount;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 8 : 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getCounterColor(turnCount).withOpacity(0.5),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Brillance en haut
          Positioned(
            top: -8,
            left: -12,
            right: -12,
            child: Container(
              height: 15,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.6),
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
                Icons.auto_awesome,
                color: Colors.white,
                size: isMobile ? 20 : 24,
                shadows: const [
                  Shadow(
                    color: Colors.black54,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ULTIMA ${isMyUltima ? "(VOUS)" : "(ADVERSAIRE)"}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 11 : 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      shadows: const [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tour $turnCount/3',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: isMobile ? 13 : 15,
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
