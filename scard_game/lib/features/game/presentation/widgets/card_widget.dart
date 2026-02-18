import 'package:flutter/material.dart';
import '../../domain/models/game_card.dart';
import '../../domain/enums/card_color.dart' as game;
import '../../domain/enums/card_type.dart';
import '../../domain/enums/card_level.dart';

/// Widget pour afficher une carte de jeu au format standard
class CardWidget extends StatelessWidget {
  final GameCard card;
  final double width;
  final double height;
  final bool compact;
  final bool showPreviewOnHover;
  final CardLevel? currentLevel;
  final String? displayTierKey;

  /// Si true et displayTierKey fourni, n'affiche que l'effet du tier sélectionné dans la preview
  final bool showOnlySelectedTier;

  /// Si true, un tap sur la carte ouvre le dialog de preview (pour mobile sur les cartes jouées)
  final bool enableTapPreview;

  const CardWidget({
    super.key,
    required this.card,
    this.width = 180,
    this.height = 280,
    this.compact = false,
    this.showPreviewOnHover = false,
    this.currentLevel,
    this.displayTierKey,
    this.showOnlySelectedTier = false,
    this.enableTapPreview = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = _getBorderColor(card.color);

    final cardWidget = SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: 1 / 1.55,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9FB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 4),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: compact ? _buildCompactLayout() : _buildFullLayout(),
        ),
      ),
    );

    if (showPreviewOnHover) {
      // Pour les cartes jouées sur le plateau, on ajoute le tap/doubleTap pour ouvrir le dialog de preview
      // (onLongPress sera réservé au drag & drop)
      if (enableTapPreview) {
        return GestureDetector(
          onTap: () => _showCardPreviewDialog(context),
          onDoubleTap: () => _showCardPreviewDialog(context),
          behavior: HitTestBehavior.opaque,
          child: cardWidget,
        );
      }

      // Pour les cartes en main: hover uniquement (desktop), pas de tap pour permettre la sélection
      // On utilise TooltipTriggerMode.manual pour éviter que le tap soit intercepté sur mobile
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Tooltip(
          richMessage: WidgetSpan(
            child: Material(
              color: Colors.transparent,
              child: CardWidget(
                card: card,
                width: 280,
                height: 440,
                compact: false,
                currentLevel: currentLevel,
                displayTierKey: displayTierKey,
                showOnlySelectedTier: showOnlySelectedTier,
              ),
            ),
          ),
          decoration: const BoxDecoration(),
          padding: EdgeInsets.zero,
          preferBelow: false,
          verticalOffset: 20,
          // Mode manuel pour ne pas intercepter les taps - le hover fonctionne toujours sur desktop
          triggerMode: TooltipTriggerMode.longPress,
          child: cardWidget,
        ),
      );
    }

    return cardWidget;
  }

  /// Affiche un dialog avec la preview de la carte (pour mobile)
  void _showCardPreviewDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder:
          (context) => GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: CardWidget(
                card: card,
                width: 280,
                height: 440,
                compact: false,
                currentLevel: currentLevel,
                displayTierKey: displayTierKey,
                showOnlySelectedTier: showOnlySelectedTier,
              ),
            ),
          ),
    );
  }

  /// Layout complet avec nom + image + effets par palier
  Widget _buildFullLayout() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          _buildTitleSection(),
          _buildImageSection(),
          _buildTierEffectsSection(),
        ],
      ),
    );
  }

  /// Layout compact pour le jeu (image + nom + type)
  Widget _buildCompactLayout() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Image principale (70% de la hauteur)
              SizedBox(
                height: constraints.maxHeight * 0.70,
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    color: Colors.grey[200],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    child:
                        card.imageUrl != null
                            ? Image.asset(
                              _normalizeAssetPath(card.imageUrl)!,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => const Icon(
                                    Icons.image_not_supported,
                                    size: 30,
                                    color: Colors.grey,
                                  ),
                            )
                            : const Icon(
                              Icons.image_not_supported,
                              size: 30,
                              color: Colors.grey,
                            ),
                  ),
                ),
              ),
              // Nom de la carte (20% de la hauteur)
              Container(
                height: constraints.maxHeight * 0.20,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(color: _getBorderColor(card.color)),
                child: Center(
                  child: Text(
                    card.name,
                    style: TextStyle(
                      fontSize: (constraints.maxHeight * 0.08).clamp(8.0, 12.0),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              // Badge type (10% de la hauteur)
              Container(
                height: constraints.maxHeight * 0.10,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Center(
                  child: Text(
                    _getCardTypeLabel(card.type),
                    style: TextStyle(
                      fontSize: (constraints.maxHeight * 0.06).clamp(6.0, 10.0),
                      fontWeight: FontWeight.w600,
                      color: _getBorderColor(card.color),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Bandeau nom de la carte
  Widget _buildTitleSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(color: _getBorderColor(card.color)),
      child: Text(
        card.name,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Tiers supérieur : Image de la carte
  Widget _buildImageSection() {
    final imageUrl = _resolveImageUrl();
    return Expanded(
      flex: 11,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          color: Colors.grey[200],
        ),
        child: ClipRRect(
          child:
              imageUrl != null
                  ? Image.asset(imageUrl, fit: BoxFit.cover)
                  : const Icon(
                    Icons.image_not_supported,
                    size: 40,
                    color: Colors.grey,
                  ),
        ),
      ),
    );
  }

  /// Tiers inférieur : Effets par palier (blanc/bleu/jaune/rouge)
  Widget _buildTierEffectsSection() {
    var effects = _parseTierEffects();

    // Si showOnlySelectedTier et displayTierKey, filtrer pour n'afficher que l'effet sélectionné
    if (showOnlySelectedTier && displayTierKey != null) {
      final tierLabel = _tierKeyToLabel(displayTierKey!);
      effects =
          effects
              .where((e) => e.label.toLowerCase() == tierLabel.toLowerCase())
              .toList();
    }

    return Expanded(
      flex: 10,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(color: Colors.grey[50]),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final effect in effects) ...[
                _buildTierBubble(effect),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Convertit un tierKey (white/blue/yellow/red) en label français
  String _tierKeyToLabel(String tierKey) {
    switch (tierKey.toLowerCase()) {
      case 'white':
        return 'Blanc';
      case 'blue':
        return 'Bleu';
      case 'yellow':
        return 'Jaune';
      case 'red':
        return 'Rouge';
      default:
        return tierKey;
    }
  }

  Widget _buildTierBubble(_TierEffect effect) {
    final isEnabled = _isTierEnabled(effect.label);
    final isWhiteTier = effect.label.trim().toLowerCase() == 'blanc';
    final border =
        isEnabled ? effect.color : Colors.grey.withValues(alpha: 0.85);
    final background =
        isEnabled
            ? (isWhiteTier
                ? const Color(0xFF5E5E5E)
                : effect.color.withValues(alpha: 0.08))
            : Colors.black.withValues(alpha: 0.12);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border.withValues(alpha: 0.7), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 3, right: 6),
            decoration: BoxDecoration(
              color:
                  isEnabled
                      ? (isWhiteTier ? Colors.white : border)
                      : Colors.grey[600],
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  if (effect.label.isNotEmpty)
                    TextSpan(
                      text:
                          effect.title != null && effect.title!.isNotEmpty
                              ? '${effect.label}: ${effect.title}\n'
                              : '${effect.label}:\n',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color:
                            isEnabled
                                ? (isWhiteTier ? Colors.white : border)
                                : Colors.grey[600],
                      ),
                    ),
                  TextSpan(
                    text: effect.text,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.25,
                      color:
                          isEnabled
                              ? (isWhiteTier ? Colors.white : Colors.black87)
                              : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_TierEffect> _parseTierEffects() {
    final raw = card.gameEffect;
    final lines =
        raw
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList();

    final colorByLabel = <String, Color>{
      'blanc': Colors.grey[700]!,
      'bleu': const Color(0xFF1E88E5),
      'jaune': const Color(0xFFF9A825),
      'rouge': const Color(0xFFE53935),
    };

    final effects = <_TierEffect>[];
    for (final line in lines) {
      final parts = line.split(':');
      if (parts.length >= 2) {
        final label = parts.first.trim();
        final text = line.substring(line.indexOf(':') + 1).trim();
        final key = label.toLowerCase();
        final color = colorByLabel[key] ?? Colors.black87;
        final tierKey = _labelToTierKey(label);
        final title = tierKey != null ? card.tierTitles[tierKey] : null;
        effects.add(
          _TierEffect(label: label, text: text, color: color, title: title),
        );
      } else {
        effects.add(
          _TierEffect(label: '', text: line.trim(), color: Colors.black87),
        );
      }
    }

    if (effects.isEmpty) {
      effects.add(
        _TierEffect(label: '', text: card.gameEffect, color: Colors.black87),
      );
    }

    return effects;
  }

  bool _isTierEnabled(String label) {
    if (currentLevel == null) return true;
    if (label.isEmpty) return true;
    final tier = _labelToLevel(label);
    if (tier == null) return true;
    return _levelRank(tier) <= _levelRank(currentLevel!);
  }

  CardLevel? _labelToLevel(String label) {
    switch (label.trim().toLowerCase()) {
      case 'blanc':
        return CardLevel.white;
      case 'bleu':
        return CardLevel.blue;
      case 'jaune':
        return CardLevel.yellow;
      case 'rouge':
        return CardLevel.red;
    }
    return null;
  }

  String? _labelToTierKey(String label) {
    switch (label.trim().toLowerCase()) {
      case 'blanc':
        return 'white';
      case 'bleu':
        return 'blue';
      case 'jaune':
        return 'yellow';
      case 'rouge':
        return 'red';
    }
    return null;
  }

  String? _resolveImageUrl() {
    // Temporairement simplifié : toujours utiliser l'image de base (blanc)
    // TODO: Réactiver les images par tier quand les nouvelles images seront prêtes
    return _normalizeAssetPath(card.imageUrl);
  }

  /// Normalise un chemin d'asset en ajoutant le préfixe 'assets/' si absent.
  /// Sur Chrome Image.asset est tolérant, mais sur Android le chemin doit être exact.
  static String? _normalizeAssetPath(String? path) {
    if (path == null) return null;
    if (path.startsWith('assets/')) return path;
    return 'assets/$path';
  }

  int _levelRank(CardLevel level) {
    switch (level) {
      case CardLevel.white:
        return 0;
      case CardLevel.blue:
        return 1;
      case CardLevel.yellow:
        return 2;
      case CardLevel.red:
        return 3;
    }
  }

  /// Récupère la couleur de bordure selon la couleur de la carte
  Color _getBorderColor(game.CardColor color) {
    switch (color) {
      case game.CardColor.white:
        return Colors.grey[600]!; // Assombri pour meilleure lisibilité
      case game.CardColor.blue:
        return const Color(0xFF2196F3);
      case game.CardColor.yellow:
        return const Color(0xFFFFC107);
      case game.CardColor.red:
        return const Color(0xFFF44336);
      case game.CardColor.green:
        return const Color(0xFF4CAF50);
    }
  }

  /// Récupère le label du type de carte
  String _getCardTypeLabel(CardType type) {
    switch (type) {
      case CardType.instant:
        return 'Éphémère';
      case CardType.ritual:
        return 'Rituel';
      case CardType.enchantment:
        return 'Enchantement';
    }
  }
}

class _TierEffect {
  final String label;
  final String text;
  final Color color;
  final String? title;

  const _TierEffect({
    required this.label,
    required this.text,
    required this.color,
    this.title,
  });
}
