import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NetworkSensitive extends StatefulWidget {
  final Widget child;
  final double opacity;

  NetworkSensitive({
    required this.child,
    this.opacity = 0.5,
  });

  @override
  State<NetworkSensitive> createState() => _NetworkSensitiveState();
}

class _NetworkSensitiveState extends State<NetworkSensitive> {
  bool isConnected = true;
  bool isChecking = false;

  checkConn() async {
    //ConnectivityService connectivity = GetIt.I.get();
    isConnected = true; //await connectivity.isOnline();
    setState(() {
      isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get our connection status from the provider
    var connectionStatus = Provider.of<ConnectivityResult?>(context);
    if (connectionStatus == null) {
      checkConn();
    }
    if (connectionStatus == ConnectivityResult.none || !isConnected) {
      return Scaffold(
          body: Center(
              child: Text("You Are Offline, please check your connection")));
      // return OfflineWidget(
      //   isChecking: isChecking,
      //   onRefresh: () {
      //     checkConn();
      //   },
      // );
    }
    return widget.child;
  }
}
