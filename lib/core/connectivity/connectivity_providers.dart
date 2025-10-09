import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectivityStatus { connected, disconnected }

final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  final connectivity = Connectivity();
  late final StreamController<ConnectivityStatus> controller;
  controller = StreamController<ConnectivityStatus>();

  Future<void> emitInitial() async {
    final initial = await connectivity.checkConnectivity();
    if (!controller.isClosed) {
      controller.add(_mapStatus(initial));
    }
  }

  emitInitial();

  final sub = connectivity.onConnectivityChanged.listen((event) {
    if (!controller.isClosed) {
      controller.add(_mapStatus(event));
    }
  });

  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });

  return controller.stream.distinct();
});

ConnectivityStatus _mapStatus(Iterable<ConnectivityResult> results) {
  if (results.isEmpty) {
    return ConnectivityStatus.disconnected;
  }

  final hasConnection = results.any((result) => result != ConnectivityResult.none);

  return hasConnection
      ? ConnectivityStatus.connected
      : ConnectivityStatus.disconnected;
}
