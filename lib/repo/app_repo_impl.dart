import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plumbata/net/api_executor.dart';
import 'package:plumbata/net/model/app_user.dart';
import 'package:plumbata/net/model/contract.dart';
import 'package:plumbata/repo/auth/auth_repo.dart';

import 'app_repo.dart';

class AppRepoImpl extends AppRepo {
  AppRepoImpl(this.apiExecutor, this.authRepo);

  final ApiExecutor apiExecutor;
  final AuthRepo authRepo;
  
  final _firestore = FirebaseFirestore.instance;

  @override
  Future<User?>? getCurrentUser() {
    return authRepo.getCurrentUser();
  }

  @override
  Future<AppUser?> getCurrentUserData() {
   return authRepo.getCurrentUserData();
  }

  @override
  Future<Contract?> getContractById(String id) async {
    try {
      var data = await _firestore.collection("contracts").doc(id).get();
      if (data.exists) {
        if (data.data() != null) {
          Contract contract = Contract.fromJson(data.data()!);
          return contract;
        }
      }
      return null;
    }catch(e){
      return null;
    }
  }
}
