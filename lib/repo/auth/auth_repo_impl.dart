import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:plumbata/net/model/app_user.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  FirebaseAuth _authClient = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Current Authenticated User.
  User? _currentUser;
  AppUser? _currentUserData;

  _refreshCurrentUser() async {
    _currentUser = null;
    _currentUser = await getCurrentUser();
  }

  @override
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }

    try {
      var authUser = FirebaseAuth.instance.currentUser;
      if (authUser == null) {
        return null;
      }
      return authUser;
    } catch (e, s) {
      print(e);
      print(s);
      return null;
    }
  }

  @override
  Future signOut() async {
    await _authClient.signOut();
    _currentUser = null;
  }

  @override
  Future signUp(String email, String password, String firstName,
      String lastName, String company, String phone, String countryCode,bool isComplete) async {
    try {
      User? user =  FirebaseAuth.instance.currentUser;

      if(isComplete){
        _firestore.collection("users").doc(user?.uid).set({
          "company": company,
          "email": user?.email ?? email.toLowerCase(),
          "firstName": firstName,
          "lastName": lastName,
          "phone": phone,
          "role": "contractor",
          "status": "active",
          "unionid": "",
          "created_time": DateTime.now(),
          "uid": user?.uid,
          "profile_image": "",
          "countryCode": countryCode,
          "contracts":[]
        });
        return;
      }
      UserCredential creds = await _authClient.createUserWithEmailAndPassword(
          email: email, password: password);

      if (creds.credential != null) {
        _authClient.signInWithCredential(creds.credential!);
      }

      _firestore.collection("users").doc(creds.user?.uid).set({
        "company": company,
        "email": user?.email ?? email.toLowerCase(),
        "firstName": firstName,
        "lastName": lastName,
        "phone": phone,
        "role": "contractor",
        "status": "active",
        "unionid": "",
        "created_time": DateTime.now(),
        "uid": creds.user?.uid,
        "profile_image": "",
        "contracts":[]
      });


    } catch (e) {
      print("Error $e");
    }
  }

  @override
  Future confirmPassword(
      String username, String newPassword, String confirmationCode) {
    // TODO: implement confirmPassword
    throw UnimplementedError();
  }

  @override
  Future resetPassword(String email) async {
    await _authClient.sendPasswordResetEmail(email: email);
  }

  @override
  Future signIn({required String username, required String password}) async {
    await _authClient.signInWithEmailAndPassword(
        email: username, password: password);
  }

  @override
  Future signInWithGoogle() async {
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
      ],
    );
    GoogleSignInAccount? account = await _googleSignIn.signIn();
    final GoogleSignInAuthentication? gAuth = await account?.authentication;
    final creds = GoogleAuthProvider.credential(
        accessToken: gAuth?.accessToken, idToken: gAuth?.idToken);

    await _authClient.signInWithCredential(creds);
  }

  Future<User?> signInWithApple() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final AppleAuthProvider appleAuthProvider = AppleAuthProvider();

    await _auth.signInWithProvider(appleAuthProvider);

    return _auth.currentUser;

  }

  @override
  Future<AppUser?> getCurrentUserData() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    try {
      if (_currentUser != null) {
        var data =
        await _firestore.collection("users").doc(_currentUser?.uid).get();
        if (data.data() != null) {
          AppUser appUser = AppUser.fromJson(data.data()!);
          _currentUserData = appUser;
          return appUser;
        }
      }
    }catch(e) {
      return null;
    }
    return null;
  }

  @override
  Future<String?> changePassword(
      {required String currentPassword, required String newPassword}) async {
    try {
      final user = await FirebaseAuth.instance.currentUser;
      final cred = EmailAuthProvider.credential(
          email: user?.email ?? "", password: currentPassword);
      await user?.reauthenticateWithCredential(cred);
      await user?.updatePassword(newPassword);
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
