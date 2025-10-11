/// ---------------------------------------------------------------------------
/// Fichier : lib/common/config/app_config.dart
/// Rôle : Charger les variables d'environnement (.env) et les exposer via une
///        API typée pour le reste de l'application.
/// Dépendances : flutter_dotenv pour le parsing .env, logger optionnel pour les
///        messages (injecté plus tard via ServiceLocator).
/// Exemple d'usage :
///   final config = AppConfig();
///   await config.load();
///   final apiBaseUrl = config.getRequired('API_BASE_URL');
/// ---------------------------------------------------------------------------
library;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// AppConfig = wrapper centralisant le chargement des variables d'environnement.
class AppConfig {
  /// Crée un AppConfig vide ; appeler [load] avant lecture.
  AppConfig();

  bool _loaded = false;

  /// Indique si le fichier .env a déjà été chargé.
  bool get isLoaded => _loaded;

  /// Charge les variables d'environnement depuis [fileName].
  ///
  /// Préconditions : le fichier doit exister dans les assets configurés.
  /// Postconditions : les paires clé/valeur sont disponibles via [getOptional].
  Future<void> load({String fileName = '.env'}) async {
    // Évite de recharger plusieurs fois le même fichier .env ; un second appel
    // devient un no-op pour empêcher des lectures redondantes.
    if (_loaded) {
      return;
    }

    // Demande à flutter_dotenv de parser le fichier et de remplir les valeurs
    // accessibles globalement via `dotenv`.
    await dotenv.load(fileName: fileName);
    // Marque l'état comme chargé afin de bloquer les futurs rechargements.
    _loaded = true;
  }

  /// Récupère une valeur optionnelle ; renvoie `null` si la clé est absente.
  String? getOptional(String key) {
    return dotenv.maybeGet(key);
  }

  /// Récupère une valeur obligatoire et lève [AppConfigMissingKeyException] si
  /// la clé est absente.
  String getRequired(String key) {
    // Commence par lire la valeur via l'API optionnelle afin de mutualiser la
    // logique d'accès au store interne de flutter_dotenv.
    final String? value = getOptional(key);
    if (value == null || value.isEmpty) {
      // Déclenche une exception explicite permettant aux appelants de savoir
      // qu'une variable critique n'est pas fournie.
      throw AppConfigMissingKeyException(key);
    }
    // À ce stade, la chaîne est non vide et peut être renvoyée directement.
    return value;
  }
}

/// Exception levée lorsqu'une clé obligatoire est absente du fichier .env.
class AppConfigMissingKeyException implements Exception {
  /// Initialise l'exception avec la [missingKey] introuvable.
  const AppConfigMissingKeyException(this.missingKey);

  /// Clé manquante.
  final String missingKey;

  @override
  String toString() => 'AppConfigMissingKeyException: "$missingKey" absente';
}
