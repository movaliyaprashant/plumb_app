import 'dart:async';

import 'package:connectivity/connectivity.dart';

abstract class ConnectivityService {
  Future<bool> isOnline();

  Future<bool> isOffline();

  Stream<bool> get onlineStream;

  Stream<bool> get offlineStream;

  Future<void> validateOnline();

  Future<String> networkType();

  StreamController<ConnectivityResult>  get connectionStatusController;
}
