import 'package:plumbata/app/plumbata.dart';
import 'package:plumbata/manager/auth_manager.dart';
import 'package:plumbata/repo/auth/auth_repo.dart';

class AuthHandler {
  final AuthRepo authRepo;

  AuthHandler(this.authRepo);

  /// On Unauthorized user, clear session and relaunch app.
  Future onAuthChanged(AuthStatus status) async {
    await authRepo.signOut();
    rootNavigatorKey.currentState
        ?.pushNamedAndRemoveUntil('/', (route) => false);
  }
}
