import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/game_card.dart';
import '../providers/deck_builder_provider.dart';
import '../widgets/simple_card_widget.dart';

/// Écran de construction de deck personnalisé
/// Permet aux joueurs de modifier leur deck (0-4 exemplaires par carte)
class DeckBuilderScreen extends ConsumerWidget {
  const DeckBuilderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deckBuilderProvider);

    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Construction de Deck')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Deck'),
        actions: [
          // Bouton de réinitialisation
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Réinitialiser au deck par défaut',
            onPressed: () => _showResetDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête avec compteur total
          _buildHeader(context, state),

          // Message d'erreur si présent
          if (state.errorMessage != null) _buildErrorBanner(context, state),

          // Grille de cartes
          Expanded(
            child: _buildCardGrid(context, ref, state),
          ),

          // Bouton de sauvegarde
          _buildSaveButton(context, ref, state),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DeckBuilderState state) {
    final isValid = state.isValid;
    final color = isValid ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(16),
      color: color.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cartes dans le deck',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '${state.totalCards} / 25',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          if (!isValid)
            Chip(
              label: Text(
                'Ajustez pour avoir 25 cartes',
                style: TextStyle(color: color),
              ),
              backgroundColor: Colors.transparent,
              side: BorderSide(color: color),
            ),
          if (isValid)
            Chip(
              label: const Text('Deck valide'),
              backgroundColor: color.withOpacity(0.2),
              avatar: Icon(Icons.check_circle, color: color, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context, DeckBuilderState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.red.shade100,
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              state.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () {
              // Utiliser ref.read dans un callback
              // On ne peut pas utiliser ref dans un ConsumerWidget build
              // mais on passera la ref via un callback
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCardGrid(
    BuildContext context,
    WidgetRef ref,
    DeckBuilderState state,
  ) {
    // Grouper les cartes par type
    final ritualCards =
        state.allCards.where((c) => c.type == 'ritual').toList();
    final enchantmentCards =
        state.allCards.where((c) => c.isEnchantment).toList();
    final greenCards =
        state.allCards.where((c) => c.color.name == 'green').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCardSection(context, ref, state, 'Cartes Rituelles', ritualCards),
        const SizedBox(height: 24),
        _buildCardSection(
          context,
          ref,
          state,
          'Enchantements',
          enchantmentCards,
        ),
        const SizedBox(height: 24),
        _buildCardSection(
          context,
          ref,
          state,
          'Cartes de Négociation',
          greenCards,
        ),
      ],
    );
  }

  Widget _buildCardSection(
    BuildContext context,
    WidgetRef ref,
    DeckBuilderState state,
    String title,
    List<GameCard> cards,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              cards.map((card) => _buildCardItem(context, ref, state, card)).toList(),
        ),
      ],
    );
  }

  Widget _buildCardItem(
    BuildContext context,
    WidgetRef ref,
    DeckBuilderState state,
    GameCard card,
  ) {
    final count = state.getCardCount(card.id);
    final maxPerCard = card.maxPerDeck ?? 4;
    final canIncrement = count < maxPerCard && state.totalCards < 25;
    final canDecrement = count > 0;

    return Container(
      width: 140,
      decoration: BoxDecoration(
        border: Border.all(
          color: count > 0 ? Colors.blue : Colors.grey.shade300,
          width: count > 0 ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Aperçu de la carte
          Container(
            height: 100,
            padding: const EdgeInsets.all(8),
            child: SimpleCardWidget(card: card),
          ),

          // Nom de la carte
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              card.name,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 8),

          // Contrôles +/-
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: count > 0 ? Colors.blue.shade50 : Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bouton -
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: canDecrement
                      ? () => ref
                          .read(deckBuilderProvider.notifier)
                          .decrementCard(card.id)
                      : null,
                  iconSize: 20,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                ),

                // Compteur
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    '$count',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: count > 0 ? Colors.blue : Colors.grey,
                        ),
                  ),
                ),

                // Bouton +
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: canIncrement
                      ? () => ref
                          .read(deckBuilderProvider.notifier)
                          .incrementCard(card.id)
                      : null,
                  iconSize: 20,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),

          // Indicateur de limite
          if (maxPerCard < 4)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'Max: $maxPerCard',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    WidgetRef ref,
    DeckBuilderState state,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state.isValid
                ? () async {
                    await ref.read(deckBuilderProvider.notifier).saveConfiguration();
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
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: Text(
              state.isValid ? 'Sauvegarder le Deck' : 'Deck incomplet',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showResetDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
