import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:get_it/get_it.dart';
import 'package:plumbata/services/connectivity/connectivity_interface.dart';

class ConnectivityServiceImpl extends ConnectivityService {
  late final Connectivity _connectivity;

  final StreamController<ConnectivityResult> _connectionStatusController =
      StreamController<ConnectivityResult>();

  //#region Initializers

  ConnectivityServiceImpl({Connectivity? connectivity}) {
    _connectivity = connectivity ?? Connectivity();
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _connectionStatusController.add(result);
    });
  }

  //#endregion

  @override
  Future<bool> isOffline() async {
    return (await _connectivity.checkConnectivity()) == ConnectivityResult.none;
  }

  @override
  Future<bool> isOnline() async {
    return (await _connectivity.checkConnectivity()) != ConnectivityResult.none;
  }

  @override
  Stream<bool> get offlineStream => _connectivity.onConnectivityChanged
      .map((event) => event == ConnectivityResult.none);

  @override
  Stream<bool> get onlineStream => _connectivity.onConnectivityChanged
      .map((event) => event != ConnectivityResult.none);

  @override
  Future<void> validateOnline() async {
    final ConnectivityService connectivityService = GetIt.I.get();
    var isOffline = await connectivityService.isOffline();
    if (isOffline) {
      throw Exception("Must have an active internet connection");
    }
  }

  @override
  Future<String> networkType() async {
    String result = '';
    switch (await _connectivity.checkConnectivity()) {
      case ConnectivityResult.mobile:
        result = 'Mobile Data';
        break;
      case ConnectivityResult.none:
        result = 'None';
        break;
      case ConnectivityResult.wifi:
        result = 'Wifi';
        break;
      default:
    }
    return result;
  }

  @override
  Connectivity get instance => _connectivity;

  @override
  StreamController<ConnectivityResult> get connectionStatusController =>
      _connectionStatusController;
}
