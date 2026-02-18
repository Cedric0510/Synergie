import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/game_card.dart';
import '../../domain/enums/card_type.dart';
import '../providers/deck_builder_provider.dart';
import '../widgets/card_widget.dart';

// Couleurs identiques à la galerie
const _kGradientColors = [
  Color(0xFF6DD5FA),
  Color(0xFF2980B9),
  Color(0xFF8E44AD),
];
const _kAppBarColor = Color(0xFF2980B9);
const _kColorRitual = Color(0xFF5B9BD5); // Bleu clair – Rituels
const _kColorEnchantment = Color(0xFF8E44AD); // Violet – Enchantements
const _kColorNegociation = Color(0xFF4CAF50); // Vert – Négociation

/// Écran de construction de deck personnalisé
class DeckBuilderScreen extends ConsumerStatefulWidget {
  const DeckBuilderScreen({super.key});

  @override
  ConsumerState<DeckBuilderScreen> createState() => _DeckBuilderScreenState();
}

class _DeckBuilderScreenState extends ConsumerState<DeckBuilderScreen> {
  /// Gère la tentative de sortie avec modifications non sauvegardées
  Future<bool> _onWillPop() async {
    final state = ref.read(deckBuilderProvider);

    if (!state.hasUnsavedChanges) {
      return true; // Pas de modifications, on peut sortir
    }

    // Afficher le dialogue de confirmation
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Modifications non sauvegardées'),
            content: const Text(
              'Vous avez des modifications non sauvegardées. '
              'Voulez-vous les sauvegarder avant de quitter ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop('discard'),
                child: const Text('Quitter sans sauvegarder'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop('cancel'),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop('save'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Sauvegarder'),
              ),
            ],
          ),
    );

    if (result == 'save') {
      // Sauvegarder puis quitter
      if (state.isValid) {
        await ref.read(deckBuilderProvider.notifier).saveConfiguration();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Deck sauvegardé !'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return true;
      } else {
        // Deck invalide, ne pas quitter
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Impossible de sauvegarder : ${state.totalCards}/25 cartes',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return false;
      }
    } else if (result == 'discard') {
      return true; // Quitter sans sauvegarder
    }

    return false; // Annulé, rester sur l'écran
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deckBuilderProvider);

    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Construction de Deck')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final canPop = await _onWillPop();
        if (canPop && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mon Deck'),
          backgroundColor: _kAppBarColor,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.restore),
              tooltip: 'Réinitialiser au deck par défaut',
              onPressed: () => _showResetDialog(context),
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _kGradientColors,
              stops: [0.0, 0.6, 1.0],
            ),
          ),
          child: Column(
            children: [
              _buildHeader(context, state),
              if (state.errorMessage != null) _buildErrorBanner(context, state),
              Expanded(child: _buildCardGrid(context, state)),
              _buildSaveButton(context, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DeckBuilderState state) {
    final isValid = state.isValid;
    final color = isValid ? Colors.green.shade400 : Colors.orange.shade400;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.style, color: color, size: 26),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cartes dans le deck',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${state.totalCards} / 25',
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Chip(
            label: Text(
              isValid ? 'Deck valide ✓' : 'Ajustez à 25 cartes',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            backgroundColor: color.withValues(alpha: 0.15),
            side: BorderSide(color: color),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context, DeckBuilderState state) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              state.errorMessage!,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.redAccent),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCardGrid(BuildContext context, DeckBuilderState state) {
    final ritualCards =
        state.allCards.where((c) => c.type == CardType.ritual).toList();
    final enchantmentCards =
        state.allCards.where((c) => c.isEnchantment).toList();
    final greenCards =
        state.allCards.where((c) => c.color.name == 'green').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (ritualCards.isNotEmpty) ...[
          _buildCardSection(
            context,
            state,
            'Cartes Rituelles',
            Icons.auto_fix_high,
            ritualCards,
            _kColorRitual,
          ),
          const SizedBox(height: 24),
        ],
        if (enchantmentCards.isNotEmpty) ...[
          _buildCardSection(
            context,
            state,
            'Enchantements',
            Icons.brightness_5,
            enchantmentCards,
            _kColorEnchantment,
          ),
          const SizedBox(height: 24),
        ],
        if (greenCards.isNotEmpty) ...[
          _buildCardSection(
            context,
            state,
            'Négociations',
            Icons.handshake,
            greenCards,
            _kColorNegociation,
          ),
          const SizedBox(height: 16),
        ],
        if (state.allCards.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'Aucune carte chargée',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.white70),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCardSection(
    BuildContext context,
    DeckBuilderState state,
    String title,
    IconData icon,
    List<GameCard> cards,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header style galerie
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: 2),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                '${cards.length} cartes',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.52,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: cards.length,
          itemBuilder:
              (context, index) =>
                  _buildCardItem(context, state, color, cards[index]),
        ),
      ],
    );
  }

  Widget _buildCardItem(
    BuildContext context,
    DeckBuilderState state,
    Color sectionColor,
    GameCard card,
  ) {
    final count = state.getCardCount(card.id);
    final maxPerCard = card.maxPerDeck ?? 4;
    final canIncrement = count < maxPerCard && state.totalCards < 25;
    final canDecrement = count > 0;
    final activeColor = count > 0 ? sectionColor : Colors.white60;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(
          color: count > 0 ? sectionColor : Colors.white30,
          width: count > 0 ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Carte complète avec détails
          Expanded(
            child: GestureDetector(
              onTap: () => _showCardPreview(context, card),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: CardWidget(
                  card: card,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),

          // Barre +/-
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            decoration: BoxDecoration(
              color:
                  count > 0
                      ? sectionColor.withValues(alpha: 0.20)
                      : Colors.white.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bouton -
                Expanded(
                  child: InkWell(
                    onTap:
                        canDecrement
                            ? () => ref
                                .read(deckBuilderProvider.notifier)
                                .decrementCard(card.id)
                            : null,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Icon(
                        Icons.remove,
                        size: 16,
                        color: canDecrement ? activeColor : Colors.white24,
                      ),
                    ),
                  ),
                ),

                // Compteur
                Expanded(
                  child: Text(
                    '$count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Bouton +
                Expanded(
                  child: InkWell(
                    onTap:
                        canIncrement
                            ? () => ref
                                .read(deckBuilderProvider.notifier)
                                .incrementCard(card.id)
                            : null,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Icon(
                        Icons.add,
                        size: 16,
                        color: canIncrement ? activeColor : Colors.white24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Indicateur de limite
          if (maxPerCard < 4)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                'Max: $maxPerCard',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Affiche la carte en plein écran dans un dialog
  void _showCardPreview(BuildContext context, GameCard card) {
    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 40,
            ),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Center(
                  child: CardWidget(
                    card: card,
                    width: MediaQuery.of(ctx).size.width - 48,
                    height: (MediaQuery.of(ctx).size.width - 48) * 1.55,
                  ),
                ),
                // Bouton fermer
                Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.of(ctx).pop(),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildSaveButton(BuildContext context, DeckBuilderState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: Icon(
              state.isValid ? Icons.save : Icons.warning_amber_rounded,
              size: 20,
            ),
            label: Text(
              state.isValid
                  ? 'Sauvegarder le Deck'
                  : 'Deck incomplet (${state.totalCards}/25)',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            onPressed:
                state.isValid
                    ? () async {
                      await ref
                          .read(deckBuilderProvider.notifier)
                          .saveConfiguration();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Deck sauvegardé !'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    }
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kAppBarColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.white24,
              disabledForegroundColor: Colors.white54,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showResetDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Réinitialiser le deck ?'),
            content: const Text(
              'Voulez-vous réinitialiser votre deck à la configuration par défaut ? '
              'Toutes vos modifications seront perdues.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Réinitialiser'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(deckBuilderProvider.notifier).resetToDefault();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deck réinitialisé'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    }
  }
}
