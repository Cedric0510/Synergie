import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/card_service.dart';
import '../../../domain/models/game_card.dart';
import '../card_widget.dart';

/// Affichage compact des enchantements avec chevauchement après 3 cartes
class CompactEnchantementsWidget extends ConsumerWidget {
  final List<String> enchantmentIds;
  final bool isMyEnchantments;
  final Function(String enchantmentId, GameCard card)? onEnchantmentTap;
  final double scale;
  final Map<String, String> enchantmentTiers;

  const CompactEnchantementsWidget({
    super.key,
    required this.enchantmentIds,
    this.isMyEnchantments = false,
    this.onEnchantmentTap,
    this.scale = 1.0,
    this.enchantmentTiers = const {},
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (enchantmentIds.isEmpty) return const SizedBox.shrink();

    final cardService = ref.watch(cardServiceProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isSmallMobile = screenWidth < 380; // Très petits écrans

    // Tailles adaptatives selon l'écran
    final baseCardWidth = isSmallMobile ? 32.0 : (isMobile ? 38.0 : 50.0);
    final baseCardHeight = isSmallMobile ? 42.0 : (isMobile ? 48.0 : 65.0);
    final baseOverlapOffset = isSmallMobile ? 10.0 : (isMobile ? 12.0 : 15.0);
    final cardWidth = (baseCardWidth * scale).clamp(18.0, baseCardWidth);
    final cardHeight = (baseCardHeight * scale).clamp(24.0, baseCardHeight);
    final overlapOffset =
        (baseOverlapOffset * scale).clamp(6.0, baseOverlapOffset);

    return FutureBuilder(
      future: cardService.loadAllCards(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final allCards = snapshot.data!;

        // Créer une liste d'enchantements en respectant les doublons
        final enchantments =
            enchantmentIds.map((id) {
              return allCards.firstWhere((card) => card.id == id);
            }).toList();

        if (enchantments.isEmpty) return const SizedBox.shrink();

        // Calculer la largeur totale nécessaire
        final totalWidth =
            enchantments.length <= 3
                ? enchantments.length *
                    (cardWidth + 4) // Espacées normalement
                : (cardWidth +
                    (enchantments.length - 1) * overlapOffset); // Chevauchées

        return SizedBox(
          width: totalWidth,
          height: cardHeight + 10,
          child: Stack(
            children: [
              for (int i = 0; i < enchantments.length; i++)
                Positioned(
                  left:
                      enchantments.length <= 3
                          ? i *
                              (cardWidth + 4) // Côte à côte si <= 3
                          : i * overlapOffset, // Chevauchement si > 3
                  child: GestureDetector(
                    onTap:
                        isMyEnchantments && onEnchantmentTap != null
                            ? () => onEnchantmentTap!(
                              enchantmentIds[i],
                              enchantments[i],
                            )
                            : null,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: CardWidget(
                        card: enchantments[i],
                        width: cardWidth,
                        height: cardHeight,
                        compact: true,
                        showPreviewOnHover: true,
                        displayTierKey: enchantmentTiers[enchantmentIds[i]],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
