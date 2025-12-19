# Mécaniques Spéciales des Cartes S'Card

## ✅ Déjà implémenté

### white_008 - Echange
```json
"mechanics": [{
  "type": "sacrificeCard",
  "target": "ownHand",
  "count": 1,
  "replaceSpell": true
}]
```

## 📋 À implémenter

### white_003 - Désenchanter
```json
"mechanics": [{
  "type": "destroyEnchantment",
  "target": "anyEnchantment",
  "count": 1
}]
```

### blue_001 - Déshabillage X2
```json
"mechanics": [{
  "type": "playerChoice",
  "conditions": {
    "choices": ["sacrificeEnchantment", "discardCard"]
  }
}]
```

### blue_002 - Rhabillage
```json
"mechanics": [{
  "type": "discardCard",
  "target": "ownHand",
  "count": 1
}]
```

### blue_004 - Révélation
```json
"mechanics": [
  {
    "type": "destroyEnchantment",
    "target": "anyEnchantment",
    "count": 1
  },
  {
    "type": "drawCards",
    "count": 2,
    "additionalActions": {
      "bothPlayers": true
    }
  }
]
```

### blue_007 - Rebuild
```json
"mechanics": [{
  "type": "shuffleHandIntoDeck",
  "additionalActions": {
    "drawCount": "handSize"
  }
}]
```

### blue_008 - Ping Pong
```json
"mechanics": [{
  "type": "drawUntil",
  "filter": "color:red",
  "additionalActions": {
    "minigame": "pingPong"
  }
}]
```

### blue_009 - 5mn
```json
"mechanics": [{
  "type": "turnCounter",
  "initialCounterValue": 5,
  "additionalActions": {
    "delaySpell": true,
    "penaltyOnExpire": 5
  }
}]
```

### blue_010 - Magiiie
```json
"mechanics": [{
  "type": "drawCards",
  "count": 1,
  "replaceSpell": true,
  "conditions": {
    "mustBePlayableInPhase": true
  }
}]
```

### blue_013 - Bisous (enchantement)
```json
"mechanics": [{
  "type": "replaceEnchantment",
  "target": "anyEnchantment",
  "count": 1
}]
```

### yellow_002 - Tentation
```json
"mechanics": [{
  "type": "playerChoice",
  "target": "opponentEnchantment",
  "conditions": {
    "choices": ["destroyEnchantment", "opponentDrawsAndGains"]
  }
}]
```

### yellow_007 - Miroir X2
```json
"mechanics": [
  {
    "type": "sacrificeCard",
    "target": "ownEnchantment",
    "count": 1
  },
  {
    "type": "drawCards",
    "count": 1,
    "additionalActions": {
      "copyOriginalSpell": true,
      "applyBothSpells": true
    }
  }
]
```

### yellow_008 - Absolution
```json
"mechanics": [{
  "type": "destroyAllEnchantments",
  "target": "ownEnchantment",
  "additionalActions": {
    "gainPIPerDestroyed": 2,
    "conditionalOpponentDestroy": true
  }
}]
```

### yellow_009 - A mon niveau
```json
"mechanics": [{
  "type": "conditionalCounter",
  "conditions": {
    "checkColorVsLevel": true
  }
}]
```

### yellow_010 - Transformation
```json
"mechanics": [{
  "type": "conditionalCounter",
  "conditions": {
    "checkIntensityLevel": true
  }
}]
```

### yellow_011 - Piège (enchantement)
```json
"mechanics": [{
  "type": "counterBased",
  "counterSource": "clothingCount",
  "initialCounterValue": 1,
  "additionalActions": {
    "autoCounterOnTarget": true,
    "removeChargeOnCounter": true,
    "destroyAtZero": true
  }
}]
```

### yellow_012 - Bisous coquin (enchantement)
```json
"mechanics": [{
  "type": "replaceEnchantment",
  "target": "anyEnchantment",
  "count": 1
}]
```

### red_008 - Bis
```json
"mechanics": [{
  "type": "replaceSpell",
  "additionalActions": {
    "usePreviousSpell": true
  }
}]
```

### red_009 - Reset
```json
"mechanics": [
  {
    "type": "shuffleHandIntoDeck"
  },
  {
    "type": "drawCards",
    "count": 3
  },
  {
    "type": "conditionalCounter",
    "conditions": {
      "requiresNudityCheck": true
    }
  }
]
```

### red_010 - Echange de plaisir
```json
"mechanics": [{
  "type": "drawUntil",
  "filter": "name:Plaisir",
  "replaceSpell": true,
  "additionalActions": {
    "targetReceivesBenefit": true
  }
}]
```

### red_012 - Morphose
```json
"mechanics": [
  {
    "type": "destroyEnchantment",
    "target": "anyEnchantment",
    "count": 1
  },
  {
    "type": "drawUntil",
    "filter": "color:white,type:enchantment",
    "count": 1,
    "replaceSpell": true
  }
]
```

### red_013 - Caresse ou rien (enchantement)
```json
"mechanics": [{
  "type": "replaceEnchantment",
  "target": "anyEnchantment",
  "count": 1
}]
```

### red_014 - Gagné? (enchantement)
```json
"mechanics": [
  {
    "type": "replaceEnchantment",
    "target": "anyEnchantment",
    "count": 1
  },
  {
    "type": "playerChoice",
    "additionalActions": {
      "lockPI": true,
      "forceActions": true
    }
  }
]
```

### red_015 - Extase (enchantement)
```json
"mechanics": [
  {
    "type": "replaceEnchantment",
    "target": "opponentEnchantment",
    "count": 1
  },
  {
    "type": "playerChoice",
    "additionalActions": {
      "payPIOrDestroy": 2
    }
  }
]
```

### red_016 - Ultima (enchantement)
```json
"mechanics": [{
  "type": "turnCounter",
  "initialCounterValue": 3,
  "additionalActions": {
    "winOnExpire": true
  },
  "conditions": {
    "requiresOpponentPI": 0,
    "requiresOpponentNude": true,
    "requiresMorePI": true
  }
}]
```
