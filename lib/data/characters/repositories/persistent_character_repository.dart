/// ---------------------------------------------------------------------------
/// Fichier : lib/data/characters/repositories/persistent_character_repository.dart
/// Rôle : Adapter de persistance durable pour `CharacterRepository` basé sur un
///        fichier JSON stocké dans le répertoire applicatif.
/// Dépendances : `dart:io`, `dart:convert`, `path_provider`, `path`, entité
///        `Character`, value objects domaine.
/// Exemple d'usage :
///   final repo = PersistentCharacterRepository();
///   await repo.save(character);
/// ---------------------------------------------------------------------------
library;

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/repositories/character_repository.dart';
import 'package:sw5e_manager/domain/characters/value_objects/ability_score.dart';
import 'package:sw5e_manager/domain/characters/value_objects/background_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_name.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_trait.dart';
import 'package:sw5e_manager/domain/characters/value_objects/class_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/credits.dart';
import 'package:sw5e_manager/domain/characters/value_objects/defense.dart';
import 'package:sw5e_manager/domain/characters/value_objects/encumbrance.dart';
import 'package:sw5e_manager/domain/characters/value_objects/equipment_item_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/hit_points.dart';
import 'package:sw5e_manager/domain/characters/value_objects/initiative.dart';
import 'package:sw5e_manager/domain/characters/value_objects/level.dart';
import 'package:sw5e_manager/domain/characters/value_objects/maneuvers_known.dart';
import 'package:sw5e_manager/domain/characters/value_objects/proficiency_bonus.dart';
import 'package:sw5e_manager/domain/characters/value_objects/quantity.dart';
import 'package:sw5e_manager/domain/characters/value_objects/skill_proficiency.dart';
import 'package:sw5e_manager/domain/characters/value_objects/species_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/superiority_dice.dart';
import 'package:sw5e_manager/domain/characters/value_objects/trait_id.dart';

/// Type alias afin de faciliter l'injection d'un fournisseur de répertoire.
typedef DirectoryProvider = Future<Directory> Function();

/// PersistentCharacterRepository = implémentation durable via fichier JSON.
///
/// Cette implémentation écrit les personnages dans un fichier `characters.json`
/// situé dans le dossier documents de l'application (ou tout autre dossier
/// fourni lors des tests). Chaque entrée est stockée sous forme de Map<String,
/// dynamic> permettant une sérialisation/désérialisation simple.
class PersistentCharacterRepository implements CharacterRepository {
  PersistentCharacterRepository({
    DirectoryProvider? directoryProvider,
    String? fileName,
  })  : _directoryProvider =
            directoryProvider ?? getApplicationDocumentsDirectory,
        _fileName = fileName ?? 'characters.json';

  final DirectoryProvider _directoryProvider;
  final String _fileName;
  File? _cachedFile;

  Future<File> _ensureFile() async {
    if (_cachedFile != null) {
      return _cachedFile!;
    }

    final Directory directory = await _directoryProvider();
    final File file = File(p.join(directory.path, _fileName));

    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString(jsonEncode(<Map<String, dynamic>>[]),
          flush: true);
    }

    _cachedFile = file;
    return file;
  }

  Future<List<Map<String, dynamic>>> _readAllRecords() async {
    final File file = await _ensureFile();
    final String raw = await file.readAsString();

    if (raw.trim().isEmpty) {
      return <Map<String, dynamic>>[];
    }

    final dynamic decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('Le fichier de persistance doit contenir une liste JSON.');
    }

    return decoded.map<Map<String, dynamic>>((dynamic entry) {
      if (entry is Map<String, dynamic>) {
        return Map<String, dynamic>.from(entry);
      }
      if (entry is Map) {
        return entry.map<String, dynamic>(
          (dynamic key, dynamic value) => MapEntry(key as String, value),
        );
      }
      throw const FormatException('Entrée invalide dans le fichier de persistance.');
    }).toList();
  }

  Future<void> _writeAllRecords(List<Map<String, dynamic>> records) async {
    final File file = await _ensureFile();
    await file.writeAsString(jsonEncode(records), flush: true);
  }

  @override
  Future<void> save(Character character) async {
    final List<Map<String, dynamic>> records = await _readAllRecords();
    final Map<String, dynamic> serialized = _serialize(character);
    final int index =
        records.indexWhere((record) => record['id'] == character.id.value);

    if (index >= 0) {
      records[index] = serialized;
    } else {
      records.add(serialized);
    }

    await _writeAllRecords(records);
  }

  @override
  Future<Character?> loadLast() async {
    final List<Map<String, dynamic>> records = await _readAllRecords();
    if (records.isEmpty) {
      return null;
    }
    return _deserialize(records.last);
  }

  @override
  Future<List<Character>> listAll() async {
    final List<Map<String, dynamic>> records = await _readAllRecords();
    return List<Character>.unmodifiable(
      records.map<Character>(_deserialize),
    );
  }

  @override
  Future<Character?> loadById(CharacterId id) async {
    final List<Map<String, dynamic>> records = await _readAllRecords();
    for (final Map<String, dynamic> record in records.reversed) {
      if (record['id'] == id.value) {
        return _deserialize(record);
      }
    }
    return null;
  }

  Map<String, dynamic> _serialize(Character character) {
    return <String, dynamic>{
      'id': character.id.value,
      'name': character.name.value,
      'speciesId': character.speciesId.value,
      'classId': character.classId.value,
      'backgroundId': character.backgroundId.value,
      'level': character.level.value,
      'abilities': character.abilities.map(
        (String key, AbilityScore value) => MapEntry(key, value.value),
      ),
      'skills': character.skills
          .map((SkillProficiency skill) => <String, dynamic>{
                'skillId': skill.skillId,
                'state': skill.state.name,
                'sources': skill.sources.map((source) => source.name).toList(),
              })
          .toList(),
      'proficiencyBonus': character.proficiencyBonus.value,
      'hitPoints': character.hitPoints.value,
      'defense': character.defense.value,
      'initiative': character.initiative.value,
      'credits': character.credits.value,
      'inventory': character.inventory
          .map((InventoryLine line) => <String, dynamic>{
                'itemId': line.itemId.value,
                'quantity': line.quantity.value,
              })
          .toList(),
      'encumbrance': character.encumbrance.grams,
      'maneuversKnown': character.maneuversKnown.value,
      'superiorityDice': <String, dynamic>{
        'count': character.superiorityDice.count,
        'die': character.superiorityDice.die,
      },
      'speciesTraits': character.speciesTraits
          .map((CharacterTrait trait) => trait.id.value)
          .toList(),
    };
  }

  Character _deserialize(Map<String, dynamic> record) {
    return Character(
      id: CharacterId(record['id'] as String),
      name: CharacterName(record['name'] as String),
      speciesId: SpeciesId(record['speciesId'] as String),
      classId: ClassId(record['classId'] as String),
      backgroundId: BackgroundId(record['backgroundId'] as String),
      level: Level(record['level'] as int),
      abilities:
          Map<String, dynamic>.from(record['abilities'] as Map<dynamic, dynamic>)
              .map(
        (String key, dynamic value) =>
            MapEntry(key, AbilityScore((value as num).toInt())),
      ),
      skills: (record['skills'] as List<dynamic>)
          .map<SkillProficiency>((dynamic entry) {
        final Map<String, dynamic> skill =
            Map<String, dynamic>.from(entry as Map<dynamic, dynamic>);
        return SkillProficiency(
          skillId: skill['skillId'] as String,
          state: ProficiencyState.values.firstWhere(
            (ProficiencyState element) => element.name == skill['state'],
          ),
          sources: (skill['sources'] as List<dynamic>).map<ProficiencySource>(
            (dynamic raw) {
              final String name = raw as String;
              return ProficiencySource.values.firstWhere(
                (ProficiencySource source) => source.name == name,
              );
            },
          ),
        );
      }).toSet(),
      proficiencyBonus:
          ProficiencyBonus((record['proficiencyBonus'] as num).toInt()),
      hitPoints: HitPoints((record['hitPoints'] as num).toInt()),
      defense: Defense((record['defense'] as num).toInt()),
      initiative: Initiative((record['initiative'] as num).toInt()),
      credits: Credits((record['credits'] as num).toInt()),
      inventory: (record['inventory'] as List<dynamic>)
          .map<InventoryLine>((dynamic entry) {
        final Map<String, dynamic> item =
            Map<String, dynamic>.from(entry as Map<dynamic, dynamic>);
        return InventoryLine(
          itemId: EquipmentItemId(item['itemId'] as String),
          quantity: Quantity((item['quantity'] as num).toInt()),
        );
      }).toList(),
      encumbrance: Encumbrance((record['encumbrance'] as num).toInt()),
      maneuversKnown:
          ManeuversKnown((record['maneuversKnown'] as num).toInt()),
      superiorityDice: () {
        final Map<String, dynamic> dice = Map<String, dynamic>.from(
          record['superiorityDice'] as Map<dynamic, dynamic>,
        );
        return SuperiorityDice(
          count: (dice['count'] as num).toInt(),
          die: dice['die'] == null ? null : (dice['die'] as num).toInt(),
        );
      }(),
      speciesTraits: (record['speciesTraits'] as List<dynamic>)
          .map<CharacterTrait>((dynamic entry) => CharacterTrait(
                id: TraitId(entry as String),
              ))
          .toSet(),
    );
  }
}
