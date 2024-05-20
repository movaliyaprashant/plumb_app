import 'package:firebase_auth/firebase_auth.dart';
import 'package:plumbata/net/model/app_user.dart';

abstract class AuthRepo {

  Future<User?> getCurrentUser();

  Future<AppUser?> getCurrentUserData();

  Future signIn({required String username, required String password});

  Future signInWithGoogle();

  Future signInWithApple();

  Future signOut();

  Future<String?> changePassword({required String currentPassword, required String newPassword});

  Future signUp(
    String email,
    String password,
    String firstName,
    String lastName,
    String company,
    String phone,
    String countryCode,
    bool isComplete
  );

  Future resetPassword(String username);

  Future confirmPassword(
    String username,
    String newPassword,
    String confirmationCode,
  );

}
