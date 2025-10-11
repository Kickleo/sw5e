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
import 'package:sw5e_manager/domain/characters/value_objects/character_effect.dart';
import 'package:sw5e_manager/domain/characters/value_objects/species_id.dart';

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
    };
  }

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
    return CharacterDraft(
      name: raw['name'] as String?,
      species: species,
    );
  }
}
