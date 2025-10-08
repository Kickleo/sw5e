# Catalogue SW5e — Spécification (snapshot)

## Métadonnées
- `rules_version`: "2025-10-06" (doit matcher ADR-0002)
- Encodage: UTF-8, JSON sans commentaires

## Fichiers attendus (MVP)
- `assets/catalog/species.json`
- `assets/catalog/classes.json`
- `assets/catalog/backgrounds.json`
- `assets/catalog/skills.json`
- `assets/catalog/equipment.json`
- `assets/catalog/maneuvers.json`
- `assets/catalog/formulas.json` (HP/Defense/Initiative, etc.)

## Schémas minimaux (extraits)

### `species.json` (array)
```json
[
    {
        "id": "human",
        "name": 
        { 
            "en": "Human", 
            "fr": "Humain" 
        },
        "ability_bonuses": 
        [ 
            { 
                "ability": "any", 
                "amount": 1, 
                "count": 2 
            } 
        ],
        "traits": 
        [ 
            { 
                "id": "versatile", 
                "text": 
                { 
                    "en": "...", 
                    "fr": "..." 
                } 
            } 
        ],
        "size": "medium",
        "speed": 30
    }
]
```
### `classes.json` (array)
```json
[
    {
        "id": "guardian",
        "name": { "en": "Guardian", "fr": "Gardien" },
        "hit_die": 10,
        "level1": {
        "proficiencies": { "skills_choose": 2, "skills_from": ["athletics","perception"] },
        "starting_credits": 150,
        "starting_equipment": [{ "id": "vibroblade", "qty": 1 }]
        }
    }
]
```

### `backgrounds.json` (array)
```json
[
    {
        "id": "outlaw",
        "name": 
        { 
            "en": "Outlaw", 
            "fr": "Hors-la-loi" 
        },
        "granted_skills": 
        [
            "stealth", 
            "deception"
        ],
        "feature": 
        { 
            "id": "criminal-contact", 
            "text": 
            { 
                "en": "...", 
                "fr": "..." 
            } 
        }
    }
]
```

### `skills.json` (array)
```json
[
    { 
        "id": "perception", 
        "ability": "wis" 
    },
    { 
        "id": "athletics", 
        "ability": "str" 
    }
]
```

### `equipment.json` (array)
```json
[
    { 
        "id": "blaster-pistol", 
        "name": { 
            "en": "Blaster Pistol", 
            "fr": "Pistolet Blaster" 
        },
        "type": "weapon",
        "weight_g": 800,
        "cost": 200 
    }
]
```

### `maneuvers.json` (array)
```json
[
    { 
        "id": 
        "parry", 
        "name": 
        { 
            "en": "Parry", 
            "fr": "Parade" 
        }, 
        "die": 8, 
        "text": 
        { 
            "en": "...", 
            "fr": "..." 
        } 
    }
]
```

### `formulas.json` (objet)
```json
{
    "hp_level1": "max(hit_die) + mod(CON)",
    "defense_base": "armor_base + mod(DEX) + shield + misc",
    "initiative": "mod(DEX) + misc",
    "superiority_dice": 
    { 
        "guardian": 
        { 
            "count": 0, 
            "die": null 
        }
    }
}
```
