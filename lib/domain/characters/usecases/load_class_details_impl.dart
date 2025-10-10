/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/load_class_details_impl.dart
/// Rôle : Implémenter [LoadClassDetails] via le [CatalogRepository].
/// Dépendances : CatalogRepository, AppResult/DomainError.
/// Exemple d'usage :
///   final useCase = LoadClassDetailsImpl(repository);
///   final result = await useCase('guardian');
/// ---------------------------------------------------------------------------
library;
import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

import 'package:sw5e_manager/domain/characters/usecases/load_class_details.dart';

/// Implémentation par défaut basée sur l'adapter catalogue offline.
class LoadClassDetailsImpl implements LoadClassDetails {
  /// Crée l'instance.
  const LoadClassDetailsImpl(this._catalog);

  final CatalogRepository _catalog;

  @override
  Future<AppResult<QuickCreateClassDetails>> call(String classId) async {
    try {
      final ClassDef? classDef = await _catalog.getClass(classId);
      if (classDef == null) {
        return appErr(
          DomainError(
            'UnknownClass',
            message: 'Classe "$classId" introuvable dans le catalogue.',
          ),
        );
      }

      final ClassLevel1Proficiencies prof = classDef.level1.proficiencies;
      final bool allowsAny = prof.skillsFrom.contains('any');
      final Iterable<String> filtered =
          prof.skillsFrom.where((String id) => id != 'any');
      List<String> available;
      if (allowsAny) {
        available = await _catalog.listSkills();
      } else {
        available = filtered.toList();
      }
      available.sort();

      final Map<String, SkillDef> defs = <String, SkillDef>{};
      final List<String> missing = <String>[];
      for (final String skillId in available) {
        final SkillDef? def = await _catalog.getSkill(skillId);
        if (def == null) {
          missing.add(skillId);
          continue;
        }
        defs[skillId] = def;
      }

      return appOk(
        QuickCreateClassDetails(
          classDef: classDef,
          availableSkillIds: List<String>.unmodifiable(available),
          skillDefinitions: Map<String, SkillDef>.unmodifiable(defs),
          skillChoicesRequired: prof.skillsChoose,
          missingSkillIds: List<String>.unmodifiable(missing),
        ),
      );
    } catch (Object error) {
      return appErr(
        DomainError(
          'ClassLoadFailed',
          message: error.toString(),
          details: {'classId': classId},
        ),
      );
    }
  }
}
