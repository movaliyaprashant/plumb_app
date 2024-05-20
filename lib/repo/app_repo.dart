import 'package:firebase_auth/firebase_auth.dart';
import 'package:plumbata/net/model/app_user.dart';
import 'package:plumbata/net/model/contract.dart';


abstract class AppRepo {
  const AppRepo();

  Future<User?>? getCurrentUser();

  Future<AppUser?> getCurrentUserData();

  Future<Contract?> getContractById(String id);

}
