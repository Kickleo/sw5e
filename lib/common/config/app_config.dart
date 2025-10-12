/// Chargement et mise à disposition des variables d'environnement `.env`.
///
/// Cette façade centralise les interactions avec le package `flutter_dotenv` :
/// elle s'assure que le fichier n'est chargé qu'une seule fois et offre des
/// méthodes lisibles pour récupérer des clés optionnelles ou obligatoires.
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
  /// L'appelant peut personnaliser le nom du fichier (utile pour les tests) via
  /// le paramètre [fileName].
  Future<void> load({String fileName = '.env'}) async {
    // Évite de recharger plusieurs fois le même fichier .env ; un second appel
    // devient un no-op pour empêcher des lectures redondantes.
    if (_loaded) {
      return;
    }

    // Demande à flutter_dotenv de parser le fichier et de remplir les valeurs
    // accessibles globalement via `dotenv`. Les clés deviennent alors
    // disponibles pour toutes les couches (repositories HTTP, etc.).
    await dotenv.load(fileName: fileName);
    // Marque l'état comme chargé afin de bloquer les futurs rechargements.
    _loaded = true;
  }

  /// Récupère une valeur optionnelle ; renvoie `null` si la clé est absente.
  /// Permet aux appels d'implémenter leurs propres valeurs par défaut.
  String? getOptional(String key) {
    return dotenv.maybeGet(key);
  }

  /// Récupère une valeur obligatoire et lève [AppConfigMissingKeyException] si
  /// la clé est absente ou vide. À utiliser pour les secrets critiques (token
  /// d'API, identifiants d'espace de stockage, etc.).
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
