import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:plumbata/app/plumbata.dart';
import 'package:plumbata/manager/auth_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthManagerImpl extends AuthManager {
  static const _USER_KEY = "_USER_KEY";
  static const _TOKEN_KEY = "_TOKEN_KEY";

  @override
  Future<void> onAuthChanged(AuthStatus authStatus) async {
    if (authStatus == AuthStatus.unauthorized) {
      await onLogout();
      rootNavigatorKey.currentState?.pushNamedAndRemoveUntil('/', (_) => false);
    }
  }

  @override
  Future<void> onLogout() async {
    await _clearAll();
  }

  @override
  Future<User?> getUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user;
  }

  @override
  Future<void> saveUser(User user) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString(_USER_KEY, json.encode(user.uid));
  }

  @override
  Future<String?> getToken() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(_TOKEN_KEY);
  }

  @override
  Future<void> onAuthorizedUser(User user, String token) async {
    await saveUser(user);
    await _saveToken(token);
  }

  Future<void> _saveToken(String token) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString(_TOKEN_KEY, token);
  }

  Future<void> _clearAll() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.remove(_USER_KEY);
    await sp.remove(_TOKEN_KEY);
  }
}
