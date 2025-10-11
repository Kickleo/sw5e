/// ---------------------------------------------------------------------------
/// Fichier : lib/core/connectivity/connectivity_providers.dart
/// Rôle : Exposer, via Riverpod, l'état de connectivité réseau de l'appareil afin
///        de permettre aux couches UI/données de réagir aux changements.
/// Dépendances : `connectivity_plus` pour écouter l'état réseau natif, Riverpod
///        pour la distribution du flux typé.
/// Exemple d'usage :
///   final status = ref.watch(connectivityStatusProvider);
/// ---------------------------------------------------------------------------
library;

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enum décrivant les deux états simplifiés de connectivité que l'application
/// manipule.
enum ConnectivityStatus { connected, disconnected }

/// Provider Riverpod qui expose un [Stream] converti en [AsyncValue] et qui
/// diffuse chaque changement de connectivité sous forme de [ConnectivityStatus].
final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  // Instance unique `Connectivity` permettant d'interroger et d'écouter le
  // statut réseau natif (Wi-Fi, cellulaire, etc.).
  final connectivity = Connectivity();

  // Contrôleur utilisé pour convertir les notifications de `connectivity_plus`
  // en un flux de [ConnectivityStatus] simplifié.
  late final StreamController<ConnectivityStatus> controller;
  controller = StreamController<ConnectivityStatus>();

  // Fonction locale asynchrone pour pousser la valeur initiale avant toute
  // notification d'événement ; cela garantit que le consumer connaît l'état
  // courant immédiatement.
  Future<void> emitInitial() async {
    final initial = await connectivity.checkConnectivity();
    if (!controller.isClosed) {
      controller.add(_mapStatus(initial));
    }
  }

  // Déclenchement de l'émission initiale sans attendre le premier évènement du
  // stream natif.
  emitInitial();

  // Abonnement au flux de `connectivity_plus`; chaque événement natif est
  // transformé puis ajouté au contrôleur tant que celui-ci est ouvert.
  final sub = connectivity.onConnectivityChanged.listen((event) {
    if (!controller.isClosed) {
      controller.add(_mapStatus(event));
    }
  });

  // Lorsque le provider est détruit (aucun consumer restant), on libère les
  // ressources en annulant l'abonnement et en fermant le contrôleur.
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });

  // Renvoie un flux ne publiant que les changements d'état effectifs (via
  // `distinct`) afin d'éviter les rebuilds inutiles.
  return controller.stream.distinct();
});

/// Convertit la liste de [ConnectivityResult] bas niveau fournie par
/// `connectivity_plus` en notre enum simplifiée [ConnectivityStatus].
ConnectivityStatus _mapStatus(Iterable<ConnectivityResult> results) {
  // Si aucun résultat n'est renvoyé, on considère qu'il n'y a aucune connexion.
  if (results.isEmpty) {
    return ConnectivityStatus.disconnected;
  }

  // `connectivity_plus` renvoie potentiellement plusieurs entrées ; on vérifie
  // si l'une d'elles n'est pas `none` pour détecter une connectivité active.
  final hasConnection = results.any((result) => result != ConnectivityResult.none);

  return hasConnection
      ? ConnectivityStatus.connected
      : ConnectivityStatus.disconnected;
}
