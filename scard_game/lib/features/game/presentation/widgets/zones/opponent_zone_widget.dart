import 'package:flutter/material.dart';
import '../../../domain/models/player_data.dart';
import '../counters/tension_bar_widget.dart';
import '../enchantments/compact_enchantments_widget.dart';

/// Widget affichant la zone de l'adversaire
/// Contient les informations du joueur adverse (nom, points d'inhibition, tension)
/// et le nombre de cartes en main
class OpponentZoneWidget extends StatelessWidget {
  final PlayerData opponentData;

  const OpponentZoneWidget({super.key, required this.opponentData});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isSmallMobile = screenWidth < 380;

    return Container(
      padding: EdgeInsets.all(isSmallMobile ? 6 : (isMobile ? 8 : 16)),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(color: Colors.red.withOpacity(0.5), width: 2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Infos adversaire
          if (isMobile)
            _buildMobileLayout(isSmallMobile)
          else
            _buildDesktopLayout(),

          SizedBox(height: isSmallMobile ? 4 : (isMobile ? 6 : 8)),

          // Barre de tension
          TensionBarWidget(tension: opponentData.tension),

          SizedBox(height: isSmallMobile ? 2 : (isMobile ? 4 : 8)),
        ],
      ),
    );
  }

  /// Layout mobile : version verticale compacte
  Widget _buildMobileLayout(bool isSmallMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              opponentData.gender.toString().contains('male')
                  ? Icons.male
                  : Icons.female,
              color: Colors.white70,
              size: isSmallMobile ? 16 : 18,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                opponentData.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallMobile ? 12 : 14,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _buildInhibitionPointsBadge(
              isMobile: true,
              isSmallMobile: isSmallMobile,
            ),
            const SizedBox(width: 8),
            _buildHandCountBadge(isMobile: true, isSmallMobile: isSmallMobile),
          ],
        ),
        if (opponentData.activeEnchantmentIds.isNotEmpty) ...[
          SizedBox(height: isSmallMobile ? 4 : 6),
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
  Widget _buildInhibitionPointsBadge({
    required bool isMobile,
    bool isSmallMobile = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallMobile ? 6 : (isMobile ? 10 : 14),
        vertical: isSmallMobile ? 4 : (isMobile ? 6 : 8),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          isSmallMobile ? 12 : (isMobile ? 16 : 20),
        ),
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
            blurRadius: isSmallMobile ? 4 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        '${opponentData.inhibitionPoints} PI',
        style: TextStyle(
          color: Colors.white,
          fontSize: isSmallMobile ? 10 : (isMobile ? 12 : 16),
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(color: Colors.black38, offset: Offset(0, 1), blurRadius: 3),
          ],
        ),
      ),
    );
  }

  /// Badge affichant le nombre de cartes en main
  Widget _buildHandCountBadge({
    required bool isMobile,
    bool isSmallMobile = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallMobile ? 5 : (isMobile ? 8 : 12),
        vertical: isSmallMobile ? 4 : (isMobile ? 6 : 8),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          isSmallMobile ? 8 : (isMobile ? 12 : 16),
        ),
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
            blurRadius: isSmallMobile ? 4 : 8,
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
            size: isSmallMobile ? 10 : (isMobile ? 12 : 16),
            shadows: const [
              Shadow(
                color: Colors.black38,
                offset: Offset(0, 1),
                blurRadius: 3,
              ),
            ],
          ),
          SizedBox(width: isSmallMobile ? 2 : (isMobile ? 4 : 6)),
          Text(
            '${opponentData.handCardIds.length}',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallMobile ? 9 : (isMobile ? 11 : 13),
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
