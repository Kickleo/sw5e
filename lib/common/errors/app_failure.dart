/// ---------------------------------------------------------------------------
/// Fichier : lib/common/errors/app_failure.dart
/// Rôle : Centraliser la représentation des erreurs applicatives consommées
///        par la couche présentation et les vues pour appliquer la politique
///        d'erreurs documentée.
/// Dépendances : DomainError (défini dans `core/domain/result.dart`) via AppResult.
/// Exemple d'usage :
///   final failure = AppFailure.fromDomain(error);
///   logger.warn(failure.toLogMessage());
///   view.showError(failure.toDisplayMessage(includeCode: true));
/// ---------------------------------------------------------------------------
import 'package:meta/meta.dart';
import 'package:sw5e_manager/common/result/app_result.dart';

/// Catégorie fonctionnelle d'une [AppFailure].
enum AppFailureCategory {
  /// Erreur liée à une entrée invalide ou un prérequis non respecté.
  validation,

  /// Erreur liée à une ressource introuvable.
  notFound,

  /// Erreur de stockage/E/S (lecture ou écriture locale ou distante).
  storage,

  /// Erreur inattendue ou non classifiée.
  unexpected,
}

/// AppFailure = encapsulation standardisée d'une erreur propagée à l'UI.
@immutable
class AppFailure {
  const AppFailure._({
    required this.category,
    required this.code,
    this.message,
    this.details = const <String, Object?>{},
  });

  /// Crée une erreur de validation.
  factory AppFailure.validation({
    required String code,
    String? message,
    Map<String, Object?> details = const <String, Object?>{},
  }) =>
      AppFailure._(
        category: AppFailureCategory.validation,
        code: code,
        message: message,
        details: details,
      );

  /// Crée une erreur "non trouvé".
  factory AppFailure.notFound({
    required String code,
    String? message,
    Map<String, Object?> details = const <String, Object?>{},
  }) =>
      AppFailure._(
        category: AppFailureCategory.notFound,
        code: code,
        message: message,
        details: details,
      );

  /// Crée une erreur de stockage.
  factory AppFailure.storage({
    required String code,
    String? message,
    Map<String, Object?> details = const <String, Object?>{},
  }) =>
      AppFailure._(
        category: AppFailureCategory.storage,
        code: code,
        message: message,
        details: details,
      );

  /// Crée une erreur inattendue.
  factory AppFailure.unexpected({
    required String code,
    String? message,
    Map<String, Object?> details = const <String, Object?>{},
  }) =>
      AppFailure._(
        category: AppFailureCategory.unexpected,
        code: code,
        message: message,
        details: details,
      );

  /// Convertit un [DomainError] en [AppFailure] normalisée.
  factory AppFailure.fromDomain(DomainError error) {
    switch (error.code) {
      case 'InvalidPrerequisite':
      case 'InvalidAbilities':
        return AppFailure.validation(
          code: error.code,
          message: error.message,
          details: error.details,
        );
      case 'UnknownCatalogId':
      case 'UnknownClass':
      case 'UnknownSpecies':
        return AppFailure.notFound(
          code: error.code,
          message: error.message,
          details: error.details,
        );
      case 'CatalogLoadFailed':
      case 'ClassLoadFailed':
      case 'SpeciesLoadFailed':
        return AppFailure.storage(
          code: error.code,
          message: error.message,
          details: error.details,
        );
      case 'Unexpected':
      default:
        return AppFailure.unexpected(
          code: error.code,
          message: error.message,
          details: error.details,
        );
    }
  }

  /// Convertit une [Exception] générique en [AppFailure] inattendue.
  factory AppFailure.fromException(
    Object error, {
    String code = 'Unexpected',
    Map<String, Object?> details = const <String, Object?>{},
  }) =>
      AppFailure.unexpected(
        code: code,
        message: error.toString(),
        details: details,
      );

  /// Catégorie fonctionnelle (validation, storage...).
  final AppFailureCategory category;

  /// Code court permettant de tracer l'erreur (ex: `UnknownClass`).
  final String code;

  /// Message (optionnel) adapté à une lecture humaine.
  final String? message;

  /// Détails additionnels utiles pour le debug/log.
  final Map<String, Object?> details;

  static const Map<String, String> _defaultMessages = <String, String>{
    'InvalidPrerequisite': 'Pré-requis non respecté.',
    'InvalidAbilities': 'Répartition des caractéristiques invalide.',
    'UnknownCatalogId': 'Identifiant de catalogue inconnu.',
    'UnknownClass': 'Classe introuvable.',
    'UnknownSpecies': 'Espèce introuvable.',
    'CatalogLoadFailed': 'Impossible de charger le catalogue.',
    'ClassLoadFailed': 'Impossible de charger la classe demandée.',
    'SpeciesLoadFailed': 'Impossible de charger l\'espèce demandée.',
    'Unexpected': 'Erreur inattendue.',
  };

  static const Map<AppFailureCategory, String> _categoryFallback =
      <AppFailureCategory, String>{
    AppFailureCategory.validation: 'Entrée invalide.',
    AppFailureCategory.notFound: 'Ressource introuvable.',
    AppFailureCategory.storage: 'Erreur de stockage.',
    AppFailureCategory.unexpected: 'Erreur inattendue.',
  };

  /// Message prêt pour l'affichage utilisateur.
  String toDisplayMessage({bool includeCode = false}) {
    final String base = (message != null && message!.trim().isNotEmpty)
        ? message!.trim()
        : (_defaultMessages[code] ?? _categoryFallback[category]!);
    if (includeCode) {
      return '$code — $base';
    }
    return base;
  }

  /// Message enrichi pour la journalisation (code + détails).
  String toLogMessage() {
    final String label =
        message ?? _defaultMessages[code] ?? _categoryFallback[category]!;
    if (details.isEmpty) {
      return '[$code] $label';
    }
    return '[$code] $label | détails=$details';
  }

  @override
  String toString() => toLogMessage();
}
