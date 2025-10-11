/// ---------------------------------------------------------------------------
/// Fichier : lib/data/characters/repositories/persistent_character_draft_repository.dart
/// Rôle : Persister un brouillon de personnage dans un fichier JSON local.
/// ---------------------------------------------------------------------------
library;

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';
import 'package:sw5e_manager/domain/characters/repositories/character_draft_repository.dart';
import 'package:sw5e_manager/domain/characters/value_objects/background_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_effect.dart';
import 'package:sw5e_manager/domain/characters/value_objects/class_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/species_id.dart';

/// Signature d'une fonction asynchrone renvoyant le répertoire cible pour la
/// persistance (permet l'injection lors des tests).
typedef DirectoryProvider = Future<Directory> Function();

class PersistentCharacterDraftRepository implements CharacterDraftRepository {
  PersistentCharacterDraftRepository({
    DirectoryProvider? directoryProvider,
    String? fileName,
  })  : _directoryProvider = directoryProvider ?? getApplicationDocumentsDirectory,
        _fileName = fileName ?? 'character_draft.json';

  final DirectoryProvider _directoryProvider;
  final String _fileName;
  File? _cachedFile;

  /// Garantit la présence du fichier cible sur le disque et le met en cache
  /// pour les lectures/écritures ultérieures.
  Future<File> _ensureFile() async {
    if (_cachedFile != null) {
      return _cachedFile!;
    }
    final Directory directory = await _directoryProvider();
    final File file = File(p.join(directory.path, _fileName));
    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString(jsonEncode(<String, dynamic>{}), flush: true);
    }
    _cachedFile = file;
    return file;
  }

  /// Lit le JSON brut depuis le fichier persistant et effectue les conversions
  /// de type bas niveau (String -> Map) nécessaires avant désérialisation.
  Future<Map<String, dynamic>?> _readRaw() async {
    final File file = await _ensureFile();
    final String raw = await file.readAsString();
    if (raw.trim().isEmpty) {
      return null;
    }
    final dynamic decoded = jsonDecode(raw);
    if (decoded == null) {
      return null;
    }
    if (decoded is! Map) {
      throw const FormatException('Le brouillon doit être un objet JSON.');
    }
    return decoded.map<String, dynamic>(
      (dynamic key, dynamic value) => MapEntry(key as String, value),
    );
  }

  /// Sérialise les données fournies en JSON et les écrit dans le fichier associé.
  Future<void> _writeRaw(Map<String, dynamic> data) async {
    final File file = await _ensureFile();
    await file.writeAsString(jsonEncode(data), flush: true);
  }

  @override
  Future<void> save(CharacterDraft draft) async {
    await _writeRaw(_serializeDraft(draft));
  }

  @override
  Future<CharacterDraft?> load() async {
    final Map<String, dynamic>? raw = await _readRaw();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return _deserializeDraft(raw);
  }

  @override
  Future<void> clear() async {
    await _writeRaw(<String, dynamic>{});
  }

  /// Transforme l'entité métier en structure JSON (Map) prête à être persistée.
  Map<String, dynamic> _serializeDraft(CharacterDraft draft) {
    return <String, dynamic>{
      'name': draft.name,
      'species': draft.species == null
          ? null
          : <String, dynamic>{
              'id': draft.species!.speciesId.value,
              'displayName': draft.species!.displayName,
              'effects': draft.species!.effects
                  .map((CharacterEffect effect) => <String, dynamic>{
                        'source': effect.source,
                        'title': effect.title,
                        'description': effect.description,
                        'category': effect.category.name,
                      })
                  .toList(growable: false),
            },
      'class': draft.classId?.value,
      'background': draft.backgroundId?.value,
      'abilityScores': draft.abilityScores == null
          ? null
          : <String, dynamic>{
              'mode': draft.abilityScores!.mode.name,
              'assignments': draft.abilityScores!.assignments,
              'pool': draft.abilityScores!.pool,
            },
      'skills': draft.chosenSkills.toList(growable: false),
      'equipment': draft.equipment == null
          ? null
          : <String, dynamic>{
              'useStartingEquipment':
                  draft.equipment!.useStartingEquipment,
              'quantities': draft.equipment!.quantities,
            },
      'stepIndex': draft.stepIndex,
    };
  }

  /// Reconstruit une entité métier à partir du JSON stocké sur disque.
  CharacterDraft _deserializeDraft(Map<String, dynamic> raw) {
    final dynamic speciesRaw = raw['species'];
    DraftSpeciesSelection? species;
    if (speciesRaw is Map<String, dynamic>) {
      final List<CharacterEffect> effects = <CharacterEffect>[];
      final dynamic rawEffects = speciesRaw['effects'];
      if (rawEffects is List) {
        for (final dynamic entry in rawEffects) {
          if (entry is Map) {
            final String categoryName = entry['category'] as String? ?? 'passive';
            final CharacterEffectCategory category = CharacterEffectCategory
                    .values
                .firstWhere(
              (CharacterEffectCategory value) => value.name == categoryName,
              orElse: () => CharacterEffectCategory.passive,
            );
            effects.add(
              CharacterEffect(
                source: entry['source'] as String? ?? '',
                title: entry['title'] as String? ?? '',
                description: entry['description'] as String? ?? '',
                category: category,
              ),
            );
          }
        }
      }
      species = DraftSpeciesSelection(
        speciesId: SpeciesId(speciesRaw['id'] as String),
        displayName: speciesRaw['displayName'] as String? ?? '',
        effects: List<CharacterEffect>.unmodifiable(effects),
      );
    }
    ClassId? classId;
    final String? classIdRaw = raw['class'] as String?;
    if (classIdRaw != null && classIdRaw.isNotEmpty) {
      try {
        classId = ClassId(classIdRaw);
      } catch (_) {
        classId = null;
      }
    }
    BackgroundId? backgroundId;
    final String? backgroundIdRaw = raw['background'] as String?;
    if (backgroundIdRaw != null && backgroundIdRaw.isNotEmpty) {
      try {
        backgroundId = BackgroundId(backgroundIdRaw);
      } catch (_) {
        backgroundId = null;
      }
    }

    DraftAbilityScores? abilityScores;
    final dynamic abilityRaw = raw['abilityScores'];
    if (abilityRaw is Map<String, dynamic>) {
      final String? modeName = abilityRaw['mode'] as String?;
      final DraftAbilityGenerationMode mode = DraftAbilityGenerationMode.values
          .firstWhere(
            (DraftAbilityGenerationMode value) => value.name == modeName,
            orElse: () => DraftAbilityGenerationMode.standardArray,
          );
      final Map<String, int?> assignments = <String, int?>{};
      final dynamic assignmentsRaw = abilityRaw['assignments'];
      if (assignmentsRaw is Map) {
        assignmentsRaw.forEach((dynamic key, dynamic value) {
          if (key is String) {
            assignments[key] = value is num ? value.toInt() : null;
          }
        });
      }
      final List<int> pool = <int>[];
      final dynamic poolRaw = abilityRaw['pool'];
      if (poolRaw is List) {
        for (final dynamic entry in poolRaw) {
          if (entry is num) {
            pool.add(entry.toInt());
          }
        }
      }
      abilityScores = DraftAbilityScores(
        mode: mode,
        assignments: assignments,
        pool: pool,
      );
    }

    final Set<String> skills = <String>{};
    final dynamic skillsRaw = raw['skills'];
    if (skillsRaw is List) {
      for (final dynamic entry in skillsRaw) {
        if (entry is String) {
          skills.add(entry);
        }
      }
    }

    DraftEquipmentSelection? equipment;
    final dynamic equipmentRaw = raw['equipment'];
    if (equipmentRaw is Map<String, dynamic>) {
      final bool useStartingEquipment =
          equipmentRaw['useStartingEquipment'] as bool? ?? true;
      final Map<String, int> quantities = <String, int>{};
      final dynamic rawQuantities = equipmentRaw['quantities'];
      if (rawQuantities is Map) {
        rawQuantities.forEach((dynamic key, dynamic value) {
          if (key is String && value is num) {
            quantities[key] = value.toInt();
          }
        });
      }
      equipment = DraftEquipmentSelection(
        useStartingEquipment: useStartingEquipment,
        quantities: quantities,
      );
    }

    return CharacterDraft(
      name: raw['name'] as String?,
      species: species,
      classId: classId,
      backgroundId: backgroundId,
      abilityScores: abilityScores,
      chosenSkills: skills,
      equipment: equipment,
      stepIndex: _parseStepIndex(raw['stepIndex']),
    );
  }

  int? _parseStepIndex(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return null;
  }
}
