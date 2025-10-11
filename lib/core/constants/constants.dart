/// ---------------------------------------------------------------------------
/// Fichier : lib/core/constants/constants.dart
/// Rôle : Centraliser les valeurs constantes liées à l'intégration de News API.
///        Ce fichier sert de point unique pour adapter la configuration réseau.
/// ---------------------------------------------------------------------------
library;

/// URL racine utilisée pour toutes les requêtes HTTP vers News API.
const String newsAPIBaseURL = 'https://newsapi.org/v2/';

/// Clé d'API à renseigner (obtenue depuis https://newsapi.org). Laisser vide en
/// développement pour éviter les appels réseau involontaires.
const String newsApiKey = ''; // à remplacer

/// Code pays par défaut employé lors des requêtes News API si l'utilisateur ne
/// spécifie pas de localisation.
const String defaultCountry = 'us';

/// Catégorie d'articles par défaut utilisée pour filtrer les résultats.
const String defaultCategory = 'general';