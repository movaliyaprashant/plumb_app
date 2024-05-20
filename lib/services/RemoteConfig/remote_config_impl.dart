import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:plumbata/services/RemoteConfig/remote_config_interface.dart';

class RemoteConfigServiceImpl extends RemoteConfigService {

  final remoteConfig = FirebaseRemoteConfig.instance;

  @override
  Future<void> fetch() async {
    await remoteConfig.fetchAndActivate();
  }

  @override
  Future get(String name, String type) async {
    switch(type){
      case "int":
        return remoteConfig.getInt(name);
      case "bool":
        return remoteConfig.getBool(name);
      case "string":
        return remoteConfig.getString(name);
      case "json":
        var data = remoteConfig.getString(name);
        return json.decode(data);
      case "double":
        return remoteConfig.getDouble(name);
    }
    return null;
  }

  @override
  Future<void> setup() async {
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await remoteConfig.setDefaults(const {
      "version_data": "{'latest_version':'1.0.0','enforce_update':true}"
    });
  }

}