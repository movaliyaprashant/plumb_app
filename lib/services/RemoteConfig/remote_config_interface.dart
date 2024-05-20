abstract class RemoteConfigService {
  Future<void> setup();

  Future<void> fetch();

  Future<dynamic> get(String name, String type);

}


