import json

# Lire le fichier JSON
with open(r'c:\Dev\Scard\scard_game\assets\data\cards.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Ajouter les champs manquants à chaque carte
for card in data['cards']:
    # Vérifier si les champs existent déjà
    if 'drawCards' not in card:
        card['drawCards'] = 0
    if 'piDamageOpponent' not in card:
        card['piDamageOpponent'] = 0
    if 'piGainSelf' not in card:
        card['piGainSelf'] = 0
    if 'tensionIncrease' not in card:
        card['tensionIncrease'] = 0
    if 'piCost' not in card:
        card['piCost'] = 0
    if 'isEnchantment' not in card:
        # Détection automatique : si type est "enchantment"
        card['isEnchantment'] = (card.get('type') == 'enchantment')

# Écrire le fichier JSON mis à jour
with open(r'c:\Dev\Scard\scard_game\assets\data\cards.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"✅ {len(data['cards'])} cartes mises à jour avec succès!")
