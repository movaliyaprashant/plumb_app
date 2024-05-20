import 'package:firebase_auth/firebase_auth.dart';

enum AuthStatus { authorized, unauthorized }

abstract class AuthManager {
  Future<void> onAuthChanged(AuthStatus authStatus);

  Future<void> onAuthorizedUser(User user, String token);

  Future<void> onLogout();

  Future<User?> getUser();

  Future<String?> getToken();

  Future<void> saveUser(User user);
}
