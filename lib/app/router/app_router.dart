/// ---------------------------------------------------------------------------
/// Fichier : lib/app/router/app_router.dart
/// Rôle : Ré-exporter la configuration GoRouter hébergée dans la couche UI.
/// Dépendances : lib/ui/navigation/app_router.dart.
/// Exemple d'usage : `import 'package:sw5e_manager/app/router/app_router.dart';`.
/// ---------------------------------------------------------------------------
library;
// Réexporte directement le provider/instance GoRouter défini dans la couche UI
// afin d'éviter des imports circulaires depuis les couches supérieures.
export 'package:sw5e_manager/ui/navigation/app_router.dart';
