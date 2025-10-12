/// Point d'accès unique à la configuration GoRouter.
///
/// Les widgets de niveau supérieur importent ce fichier plutôt que la
/// définition concrète située dans `ui/navigation/app_router.dart` afin de
/// maintenir une séparation nette entre les couches « App » et « UI » tout en
/// évitant les cycles d'import.
library;

// Réexporte directement le provider/instance GoRouter défini dans la couche UI
// afin d'éviter des imports circulaires depuis les couches supérieures et de
// préserver l'encapsulation de la logique de navigation dans le module UI.
export 'package:sw5e_manager/ui/navigation/app_router.dart';
