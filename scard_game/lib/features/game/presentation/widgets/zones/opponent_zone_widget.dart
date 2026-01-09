import 'package:flutter/material.dart';
import '../counters/tension_bar_widget.dart';
import '../enchantments/compact_enchantments_widget.dart';

/// Widget affichant la zone de l'adversaire
/// Contient les informations du joueur adverse (nom, points d'inhibition, tension)
/// et le nombre de cartes en main
class OpponentZoneWidget extends StatelessWidget {
  final dynamic opponentData;

  const OpponentZoneWidget({super.key, required this.opponentData});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(color: Colors.red.withOpacity(0.5), width: 2),
        ),
      ),
      child: Column(
        children: [
          // Infos adversaire
          if (isMobile) _buildMobileLayout() else _buildDesktopLayout(),

          SizedBox(height: isMobile ? 6 : 8),

          // Barre de tension
          TensionBarWidget(tension: opponentData.tension),

          SizedBox(height: isMobile ? 4 : 8),
        ],
      ),
    );
  }

  /// Layout mobile : version verticale compacte
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              opponentData.gender.toString().contains('male')
                  ? Icons.male
                  : Icons.female,
              color: Colors.white70,
              size: 18,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                opponentData.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _buildInhibitionPointsBadge(isMobile: true),
            const SizedBox(width: 8),
            _buildHandCountBadge(isMobile: true),
          ],
        ),
        if (opponentData.activeEnchantmentIds.isNotEmpty) ...[
          const SizedBox(height: 6),
          CompactEnchantementsWidget(
            enchantmentIds: opponentData.activeEnchantmentIds,
          ),
        ],
      ],
    );
  }

  /// Layout desktop : version horizontale
  Widget _buildDesktopLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(
                opponentData.gender.toString().contains('male')
                    ? Icons.male
                    : Icons.female,
                color: Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                opponentData.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              _buildInhibitionPointsBadge(isMobile: false),
              const SizedBox(width: 16),
              if (opponentData.activeEnchantmentIds.isNotEmpty)
                CompactEnchantementsWidget(
                  enchantmentIds: opponentData.activeEnchantmentIds,
                ),
              const SizedBox(width: 16),
              _buildHandCountBadge(isMobile: false),
            ],
          ),
        ),
      ],
    );
  }

  /// Badge affichant les points d'inhibition
  Widget _buildInhibitionPointsBadge({required bool isMobile}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 14,
        vertical: isMobile ? 6 : 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.35),
            Colors.white.withOpacity(0.20),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Brillance en haut
          Positioned(
            top: isMobile ? -6 : -8,
            left: isMobile ? -10 : -14,
            right: isMobile ? -10 : -14,
            child: Container(
              height: isMobile ? 12 : 15,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMobile ? 16 : 20),
                  topRight: Radius.circular(isMobile ? 16 : 20),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.5),
                    Colors.white.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Text(
            '${opponentData.inhibitionPoints} PI',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 12 : 16,
              fontWeight: FontWeight.bold,
              shadows: const [
                Shadow(
                  color: Colors.black38,
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

  /// Badge affichant le nombre de cartes en main
  Widget _buildHandCountBadge({required bool isMobile}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 12,
        vertical: isMobile ? 6 : 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.15),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.style,
            color: Colors.white,
            size: isMobile ? 12 : 16,
            shadows: const [
              Shadow(
                color: Colors.black38,
                offset: Offset(0, 1),
                blurRadius: 3,
              ),
            ],
          ),
          SizedBox(width: isMobile ? 4 : 6),
          Text(
            isMobile
                ? '${opponentData.handCardIds.length}'
                : 'Main: ${opponentData.handCardIds.length}',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 11 : 13,
              fontWeight: FontWeight.w500,
              shadows: const [
                Shadow(
                  color: Colors.black38,
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
}
