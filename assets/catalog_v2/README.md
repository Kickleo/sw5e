# SW5e Catalog v2 (work in progress)

This folder prototypes the normalized data model requested for a future rewrite of the
asset catalog. Each JSON file co-locates localized strings with the rules payload so new
languages can be added without touching the application code. The schema follows the
prompt shared in the latest product discussion and focuses on a bilingual EN/FR sample
covering a handful of entries per collection.

> ⚠️ The current application still relies on the legacy `assets/catalog/` data. The new
> files exist as reference material while the migration tooling and DTOs are built.

## File inventory

- `abilities.json` – ability scores and localized descriptions.
- `skills.json` – skills mapped to their governing ability.
- `languages.json` – sample language entries with species references.
- `species.json` – sample species aligned with the unified trait and localization format.
- `traits.json` – shared trait definitions used by the sample species.
- `classes.json` – a condensed Sentinel class preview with level features and equipment.
- `archetypes.json` – a sample subclass wired to the sentinel entry.
- `backgrounds.json` – background shell using the new localized fields.
- `weapons.json`, `armors.json`, `equipment.json` – examples of the equipment schema.
- `feats.json`, `maneuvers.json`, `fighting_styles.json`, `customization_options.json` –
  demonstrate the shared effect DSL.
- `force_powers.json`, `tech_powers.json` – show the casting payload with bilingual text.
- `damage_types.json`, `weapon_properties.json`, `conditions.json` – reusable vocabularies.
- `formulas.json` – global calculation templates.
- `rules_effects_catalog.json` – reusable effect snippets.
- `indexes.json` – simple inverted index to speed up lookups.

These files purposefully keep the sample small (two species, one class, etc.) so they can
be reviewed quickly. The long-term plan is to feed them through a generator that converts
the entire Player's Handbook catalog into this normalized format.
