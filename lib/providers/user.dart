import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plumbata/net/model/app_user.dart';
import 'package:plumbata/net/model/comment_model.dart';
import 'package:plumbata/net/model/contract.dart';
import 'package:plumbata/net/model/cost_code.dart';
import 'package:plumbata/net/model/crew.dart';
import 'package:plumbata/net/model/crew_time_sheet.dart';
import 'package:plumbata/net/model/help_and_support.dart';
import 'package:plumbata/net/model/notification.dart';
import 'package:plumbata/net/model/privacy.dart';
import 'package:plumbata/net/model/shift.dart';
import 'package:plumbata/net/model/timesheet.dart';
import 'package:plumbata/net/model/worker.dart';
import 'package:plumbata/providers/base.dart';
import 'package:plumbata/repo/app_repo.dart';
import 'package:plumbata/repo/auth/auth_repo.dart';
import 'package:plumbata/services/files/files_interface.dart';
import 'package:plumbata/services/files/types.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Saves and loads information of current user session.
class UserProvider extends BaseChangeNotifier {
  final AppRepo appRepo;
  final AuthRepo authRepo;
  AppUser? currUserData;
  UserProvider(this.appRepo, this.authRepo);

  int notificationsCount = 0;

  User? _currentUser;

  List<Worker> _workers = [];
  List<Crew> _crews = [];

  List<Worker?>? get workers => _workers;
  List<Crew?>? get crews => _crews;

  Contract? currentContract;

  List<Contract?>? _contracts;
  List<Shift?>? _shifts;
  List<CostCode?>? _costCodes;
  List<Contract?>? get contracts => _contracts;

  List<Shift?>? get shifts => _shifts;

  List<CostCode?>? get costcodes => _costCodes;

  String? get recordFileName => _recordFileName;

  String? _recordFileName =
      "record_${DateTime.now().millisecondsSinceEpoch}.m4a";

  UiTimeSheet uiTimeSheet = UiTimeSheet(workers: [], crews: []);

  bool timeSheetContainsWorker(Worker worker) {
    return uiTimeSheet.workerIds.contains(worker.workerId);
  }

  bool timeSheetContainsCrew(Crew crew) {
    return uiTimeSheet.crewIds.contains(crew.crewId);
  }

  cleanUiTimesheet() {
    uiTimeSheet.workers = [];
    uiTimeSheet.workerIds = [];
    uiTimeSheet.workersCostCodes = {};
    uiTimeSheet.crews = [];
    uiTimeSheet.crewIds = [];
    uiTimeSheet.crewTimeSheet = [];
    uiTimeSheet = UiTimeSheet(workers: [], crews: []);
    notifyListeners();
  }

  addRemoveWorkerToTimesheet(Worker worker, {costCodeShifts}) {
    if (!timeSheetContainsWorker(worker)) {
      uiTimeSheet.workers.add(worker);
      uiTimeSheet.workerIds.add(worker.workerId ?? "N/A");

      uiTimeSheet.workersCostCodes[worker.workerId ?? ""] =
          costCodeShifts ?? [uiTimeSheet.defaultCostCodeShift!];
    } else {
      uiTimeSheet.workers.removeWhere((w) => w.workerId == worker.workerId);
      uiTimeSheet.workerIds.removeWhere((w) => w == worker.workerId);

      uiTimeSheet.workersCostCodes.remove(worker.workerId ?? "");
    }
    notifyListeners();
  }

  addRemoveCrewToTimesheet(Crew crew, {crewTimeSheet}) {
    if (!timeSheetContainsCrew(crew)) {
      uiTimeSheet.crews.add(crew);
      uiTimeSheet.crewIds.add(crew.crewId ?? "N/A");

      if (crewTimeSheet != null) {
        if (uiTimeSheet.crewTimeSheet == null) {
          uiTimeSheet.crewTimeSheet = [];
        }
        uiTimeSheet.crewTimeSheet?.add(crewTimeSheet);
      }
      print("uiTimeSheet.crewTimeSheet ${uiTimeSheet.crewTimeSheet}");
    } else {
      uiTimeSheet.crews.removeWhere((c) => c.crewId == crew.crewId);
      uiTimeSheet.crewIds.removeWhere((c) => c == crew.crewId);
      uiTimeSheet.crewTimeSheet
          ?.removeWhere((element) => element.crew.crewId == crew.crewId);
    }
    notifyListeners();
  }

  rejectTimesheet(String timesheetId) async {
    try {
      final _firestore = FirebaseFirestore.instance;
      await _firestore.collection("timesheets").doc(timesheetId).update({
        "status": "need_changes",
        "updated_at": DateTime.now(),
      });
    } catch (e, s) {
      print("Error Rejecting new Timesheet $e $s");
    }
  }

  approveTimesheet(String timesheetId) async {
    try {
      final _firestore = FirebaseFirestore.instance;
      await _firestore.collection("timesheets").doc(timesheetId).update({
        "status": "approved",
        "updated_at": DateTime.now(),
      });
    } catch (e, s) {
      print("Error Approving new Timesheet $e $s");
    }
  }

  esculateTimesheet(String timesheetId) async {
    try {
      final _firestore = FirebaseFirestore.instance;
      await _firestore.collection("timesheets").doc(timesheetId).update({
        "status": "escalated",
        "updated_at": DateTime.now(),
      });
    } catch (e, s) {
      print("Error Approving new Timesheet $e $s");
    }
  }

  setContracts(List<Contract?> contracts) {
    _contracts = contracts;
    notifyListeners();
  }

  setShifts(List<Shift?> shifts) {
    _shifts = shifts;
    notifyListeners();
  }

  setCostCodes(List<CostCode?> costcodes) {
    _costCodes = costcodes;
    notifyListeners();
  }

  setCurrentContract(Contract? contract) {
    currentContract = contract;
    SharedPreferences prefs = GetIt.I.get();
    print("contract ${contract}");
    prefs.setString("current_contract_id", contract?.contractId ?? "");
    notifyListeners();
  }

  User? get currentUser => _currentUser;

  setRecordFileName(name) {
    _recordFileName = name;
    notifyListeners();
  }

  init() async {
    try {
      _currentUser = await appRepo.getCurrentUser();

      currUserData = await appRepo.getCurrentUserData();

      await getContractShifts();

      if (currUserData != null) {
        await loadContractsDetails();
        notificationsCount = await getNotificationsCount();
      }
      notifyListeners();
    } catch (e) {
      print("Error INIT $e");
    }
  }

  Future<int> getNotificationsCount() async {
    List<AppNotification?> all = await getNotifications(count: true);
    print("count $all");
    int count = 0;
    for (AppNotification? n in all) {
      if (n?.read == false) {
        count += 1;
      }
    }
    return count;
  }

  Future<HelpAndSupport> getHelpAndSupport() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    var doc = await _firestore
        .collection("helpandsupport")
        .doc("helpandsupport")
        .get();
    HelpAndSupport helpAndSupport =
        HelpAndSupport.fromJson(doc.data() as Map<String, dynamic>);
    return helpAndSupport;
  }

  Future<LoginInfo> getLoginInfo() async {
    if (_currentUser == null) {
      _currentUser = await appRepo.getCurrentUser();
    }
    return LoginInfo(_currentUser != null);
  }

  Future signIn({required String username, required String password}) async {
    await authRepo.signIn(username: username, password: password);
    await FirebaseAnalytics.instance.logLogin();
    await init();
  }

  Future<List<String?>?>? createFiles(List<XFile> files) async {
    try {
      await FirebaseAnalytics.instance.logEvent(name: 'add_new_timesheet');
      final storageRef = FirebaseStorage.instance.ref();
      List<String> uploadedFilesUrls = [];
      for (XFile file in files) {
        var fileFile = File(file.path);
        final uploadTask = await storageRef
            .child("timesheets_files/${DateTime.now().millisecondsSinceEpoch}")
            .putFile(fileFile);

        final String downloadUrl = await uploadTask.ref.getDownloadURL();
        uploadedFilesUrls.add(downloadUrl);
      }
      return uploadedFilesUrls;
    } catch (e, s) {
      print("Error uploading new File $e $s");
    }
    return null;
  }

  Future createWorkersCostCodes(
      Map<String, List<CostCodeShift>> workersCostCodes) async {
    try {
      print("workersCostCodes ${workersCostCodes.toString()}");

      Map<String, List<DocumentReference>> workersCostCodesShifts = {};
      for (var key in workersCostCodes.keys) {
        if (workersCostCodes[key] != null) {
          for (CostCodeShift crewWorkersCostCodeShiftItem
              in workersCostCodes[key]!) {
            DocumentReference? reference =
                await createCostCodeShift(crewWorkersCostCodeShiftItem);
            if (reference != null) {
              if (!workersCostCodesShifts.containsKey(key)) {
                workersCostCodesShifts[key] = [];
              }
              workersCostCodesShifts[key]?.add(reference);
            }
          }
        }
      }
      return workersCostCodesShifts;
    } catch (e, s) {
      print("Error while creating workers cost codes Map $e $s");
      return [];
    }
  }

  Future createCrewTimeSheets(List<CrewTimeSheet>? crewTimesheet) async {
    try {
      List<DocumentReference?> results = [];
      FirebaseFirestore _firestore = FirebaseFirestore.instance;
      for (int i = 0; i < (crewTimesheet?.length ?? 0); i++) {
        Map<String, List<DocumentReference>> workersCostCodesShifts = {};

        for (var key
            in (crewTimesheet?[i].crewWorkersCostCodeShifts.keys as Iterable)) {
          for (CostCodeShift crewWorkersCostCodeShiftItem
              in crewTimesheet?[i].crewWorkersCostCodeShifts[key] ?? []) {
            DocumentReference? reference =
                await createCostCodeShift(crewWorkersCostCodeShiftItem);
            if (reference != null) {
              if (!workersCostCodesShifts.containsKey(key)) {
                workersCostCodesShifts[key] = [];
              }
              workersCostCodesShifts[key]?.add(reference);
            }
          }
        }
        DocumentReference resultDoc =
            await _firestore.collection("crew_timesheet").add({
          "crew": FirebaseFirestore.instance
              .collection("crews")
              .doc(crewTimesheet?[i].crew.crewId),
          "crew_workers": [
            for (Worker worker in crewTimesheet?[i].crewWorkers ?? [])
              FirebaseFirestore.instance
                  .collection("workers")
                  .doc(worker.workerId)
          ],
          "crew_workers_cost_code_shifts": workersCostCodesShifts
        });
        results.add(resultDoc);
      }
      return results;
    } catch (e, s) {
      print("Error while creating Crew Timeshhets $e $s");
      return [];
    }
  }

  Future<DocumentReference?> createCostCodeShift(
      CostCodeShift codeShift) async {
    try {
      FirebaseFirestore _firestore = FirebaseFirestore.instance;
      var doc = await _firestore.collection("cost_code_with_shift").add({
        "startTime": codeShift.startTime,
        "endTime": codeShift.endTime,
        "costCode": FirebaseFirestore.instance
            .collection("costcodes")
            .doc(codeShift.costCode?.costCodeId),
        "breakMins": codeShift.breakMins
      });

      print("createCostCodeShift ${doc.id}");
      return doc;
    } catch (e, s) {
      print("Enable to create Cost code shift $e $s");
      return null;
    }
  }

  Future<Privacy> getPrivacyAndTerms({isTerms = false}) async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    var doc;
    if (isTerms) {
      doc = await _firestore
          .collection("termsandconditions")
          .doc("termsandconditions")
          .get();
    } else {
      doc = await _firestore.collection("privacypolicies").doc("privacy").get();
    }
    Privacy privacy = Privacy.fromJson(doc.data() as Map<String, dynamic>);
    return privacy;
  }

  Future signUp({
    required email,
    required password,
    required firstName,
    required lastName,
    required company,
    required phone,
    required countryCode,
    required isComplete,
  }) async {
    await FirebaseAnalytics.instance.logSignUp(signUpMethod: "email");
    await authRepo.signUp(
        email, password, firstName, lastName, company, phone, countryCode, isComplete);
    await init();
  }

  Future signInWithApple() async {
    await authRepo.signInWithApple();
    await FirebaseAnalytics.instance.logSignUp(signUpMethod: "apple");
    await init();
    return FirebaseAuth.instance.currentUser;

  }

  Future signInWithGoogle() async {
    try {
      await authRepo.signInWithGoogle();
      await FirebaseAnalytics.instance.logSignUp(signUpMethod: "google");

      await init();
    } catch (e) {
      print("Error when sign in with google $e");
      return false;
    }
  }

  Future signOut() async {
    await authRepo.signOut();
    await FirebaseAnalytics.instance.logEvent(name: 'signOut');

    await init();
  }

  Future<XFile?> pickFile({required PickSource source}) async {
    FilesServices filesServices = GetIt.I.get();
    XFile? file = await filesServices.pickFile(source: source);
    return file;
  }

  Future<Contract?> getContractById(String id) async {
    Contract? contract = await appRepo.getContractById(id);
    return contract;
  }

  void notify() {
    notifyListeners();
  }

  Future updateUserData(data) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final _firestore = FirebaseFirestore.instance;
      await _firestore.collection("users").doc(user?.uid).update(data);
      currUserData = await appRepo.getCurrentUserData();

      return true;
    } catch (e, s) {
      print("Error with updating user data $e $s");
      return false;
    }
  }

  Future updateUserPhoto(file) async {
    final storageRef = FirebaseStorage.instance.ref();

    final fileFile;
    if (file != null) {
      fileFile = File(file!.path);
      final uploadTask = await storageRef
          .child("profileImages/${DateTime.now().millisecondsSinceEpoch}")
          .putFile(fileFile);

      final String downloadUrl = await uploadTask.ref.getDownloadURL();

      final user = FirebaseAuth.instance.currentUser;
      final _firestore = FirebaseFirestore.instance;

      _firestore.collection("users").doc(user?.uid).update({
        "profile_image": downloadUrl.toString(),
        "updated_at": DateTime.now()
      });
      print("Image Type ${downloadUrl.toString()}");
      await FirebaseAnalytics.instance.logEvent(name: 'update_profile_pic');
    }
    await init();
  }

  changePassword(
      {required String currentPassword, required String newPassword}) async {
    await FirebaseAnalytics.instance.logEvent(name: 'change_password');

    String? result = await authRepo.changePassword(
        currentPassword: currentPassword, newPassword: newPassword);
    return result;
  }

  getContractWorkers({required String contractId}) async {
    try {
      final _firestore = FirebaseFirestore.instance;
      final docs = await _firestore
          .collection("workers")
          .where("contractId", isEqualTo: FirebaseFirestore.instance.collection("contracts").doc(contractId))
          .where("isActive", isEqualTo: true)
          .orderBy("updated_at", descending: true)
          .get();


      List<Worker> workers = [];
      for (var doc in docs.docs) {
        var d = doc.data();
        workers.add(Worker(
          firstName: d["first_name"],
          lastName: d["last_name"],
          contractId: d["contractId"],
          added_by: d["added_by"],
          classification: d["classification"],
          unionId: d["unionId"],
          workerId: d["worker_id"],
          addedAt: d["added_at"],
          updatedAt: d["updated_at"],
        ));
      }
      _workers = workers;
      return workers;
    } catch (e, s) {
      print("Error getting workers $e $s ");
      return [];
    }
  }

  addNewWorker(
      {required String firstName,
      required String lastName,
      String? workerId,
      required String classification,
      required String contractId}) async {
    final _firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;
    await FirebaseAnalytics.instance.logEvent(name: 'add_new_worker');

    if (workerId != null && workerId.isNotEmpty) {
      await _firestore.collection("workers").doc(workerId).update({
        "first_name": firstName,
        "last_name": lastName,
        "classification": classification,
        "updated_at": DateTime.now(),
        "isActive": true,
      });
    } else {
      final doc = await _firestore.collection("workers").add({
        "first_name": firstName,
        "last_name": lastName,
        "classification": classification,
        "contractId":
            FirebaseFirestore.instance.collection("contracts").doc(contractId),
        "added_at": DateTime.now(),
        "updated_at": DateTime.now(),
        "unionId": "",
        "added_by":
            FirebaseFirestore.instance.collection("users").doc(user?.uid),
        "isActive": true,
      });
      doc.update({"worker_id": doc.id});
    }
  }

  deleteWorker(workerId) async {
    final _firestore = FirebaseFirestore.instance;
    await _firestore.collection("workers").doc(workerId).update({
      "isActive": false,
    });
  }

  Future<Crew?> getContractCrewById(String id) async {
    try {
      final _firestore = FirebaseFirestore.instance;
      final doc = await _firestore.collection("crews").doc(id).get();
      var d = doc.data();
      Crew crew = Crew(
          name: d?["name"],
          createdBy: d?["created_by"],
          contractId: d?["contractId"],
          updatedAt: d?['updated_at'],
          createdAt: d?["created_at"],
          crewId: d?["crew_id"],
          workers: List<DocumentReference>.from(d?["workers"]!.map((x) => x)));

      return crew;
    } catch (e, s) {
      print("Unable to get the crew $e $s");
    }
    return null;
  }

  getContractCrews({required String contractId}) async {
    final _firestore = FirebaseFirestore.instance;
    final docs = await _firestore
        .collection("crews")
        .where("contractId",
            isEqualTo: FirebaseFirestore.instance
                .collection("contracts")
                .doc(contractId))
        .where("isActive", isEqualTo: true)
        .get();
    List<Crew> crews = [];
    for (var doc in docs.docs) {
      var d = doc.data();
      crews.add(Crew(
          name: d["name"],
          createdBy: d["created_by"],
          contractId: d["contractId"],
          updatedAt: d['updated_at'],
          createdAt: d["created_at"],
          crewId: d["crew_id"],
          workers: List<DocumentReference>.from(d["workers"]!.map((x) => x))));
    }
    _crews = crews;
    return crews;
  }

  createCrew(
      {required workers,
      required name,
      required contractId,
      required bool isEdit,
      required String? crewId}) async {
    final _firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;
    List<DocumentReference> workersList = [];
    for (String w in workers) {
      workersList.add(FirebaseFirestore.instance.collection("workers").doc(w));
    }
    if (isEdit) {
      await FirebaseAnalytics.instance.logEvent(name: 'edit_crew');

      await _firestore.collection("crews").doc(crewId).update({
        "name": name,
        "workers": workersList,
        "contractId":
            FirebaseFirestore.instance.collection("contracts").doc(contractId),
        "updated_at": DateTime.now(),
        "created_by":
            FirebaseFirestore.instance.collection("users").doc(user?.uid),
        "isActive": true,
      });
    } else {
      await FirebaseAnalytics.instance.logEvent(name: 'add_new_crew');

      final doc = await _firestore.collection("crews").add({
        "name": name,
        "workers": workersList,
        "contractId":
            FirebaseFirestore.instance.collection("contracts").doc(contractId),
        "created_at": DateTime.now(),
        "updated_at": DateTime.now(),
        "created_by":
            FirebaseFirestore.instance.collection("users").doc(user?.uid),
        "isActive": true,
      });
      doc.update({"crew_id": doc.id});
    }
  }

  Future<AppUser?> getUserDataById({String? id, DocumentReference? ref}) async {
    final _firestore = FirebaseFirestore.instance;
    if (ref == null) {
      var doc = await _firestore.collection("users").doc(id).get();
      if (doc.exists) {
        return AppUser.fromJson(doc.data()!);
      }
    } else {
      var doc = await ref.get();
      if (doc.exists) {
        return AppUser.fromJson(doc.data() as Map<String, dynamic>);
      }
    }
    return null;
  }

  Future<List<AppUser?>> getContractUsersData() async {
    final _firestore = FirebaseFirestore.instance;
    List<AppUser> users = [];
    var docs = await _firestore
        .collection("users")
        .where("contracts",
            arrayContains: FirebaseFirestore.instance
                .collection("contracts")
                .doc(currentContract?.contractId ?? ""))
        .get();
    for (var doc in docs.docs) {
      users.add(AppUser.fromJson(doc.data()));
    }
    return users;
  }

  Future<List<Worker>> getWorkerListByIds({required List ids}) async {
    List<Worker> workers = [];
    for (DocumentReference id in ids) {
      var doc = await id.get();
      if (doc.exists) {
        workers.add(Worker.fromJson(doc.data() as Map<String, dynamic>));
      }
    }
    return workers;
  }

  getCostCodeById({required String costCodeId}) async {
    final _firestore = FirebaseFirestore.instance;
    final docs = await _firestore
        .collection("costcodes")
        .where("cost_code_id", isEqualTo: costCodeId)
        .get();
    List<CostCode> costCodes = [];
    for (var doc in docs.docs) {
      var json = doc.data();
      costCodes.add(CostCode(
        code: json["code"],
        contractId: json["contractId"],
        description: json["description"],
        estimatedHours: json["estimated_hours"],
        lastUpdateDate: json["last_update_date"],
        progress: json["progress"],
        completedHours: json["completed_hours"],
        addedHours: json["added_hours"],
        startDate: json["start_date"],
        createdDate: json["created_date"],
        costCodeId: json["cost_code_id"],
        createdBy: json["created_by"],
        targetCompletionDate: json["target_completion_date"],
      ));
    }
    return costCodes[0];
  }

  getCostCodes({required String contractId}) async {
    final _firestore = FirebaseFirestore.instance;
    if (contractId == '') {
      List<CostCode> list = [];
      return list;
    }
    final docs = await _firestore
        .collection("costcodes")
        .where("contractId",
            isEqualTo: FirebaseFirestore.instance
                .collection("contracts")
                .doc(contractId))
        .get();
    List<CostCode> costCodes = [];
    for (var doc in docs.docs) {
      var json = doc.data();
      costCodes.add(CostCode(
        code: json["code"],
        contractId: json["contractId"],
        description: json["description"],
        estimatedHours: json["estimated_hours"],
        lastUpdateDate: json["last_update_date"],
        progress: json["progress"],
        completedHours: json["completed_hours"],
        addedHours: json["added_hours"],
        startDate: json["start_date"],
        createdDate: json["created_date"],
        costCodeId: json["cost_code_id"],
        createdBy: json["created_by"],
        targetCompletionDate: json["target_completion_date"],
      ));
    }
    setCostCodes(costCodes);

    return costCodes;
  }

  Future<bool> addNewCostCode({
    bool isEdit = false,
    CostCode? editCostCode,
    required String code,
    required String description,
    required num estimatedHours,
    required num completedHours,
    required DateTime startDate,
    required DateTime targetCompletionDate,
  }) async {
    final _firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;

    try {
      if (isEdit) {
        await FirebaseAnalytics.instance.logEvent(name: 'edit_cost_code');

        print("editCostCode ${editCostCode?.costCodeId}");
        await _firestore
            .collection("costcodes")
            .doc(editCostCode?.costCodeId)
            .update({
          "code": code,
          "description": description,
          "estimated_hours": estimatedHours,
          "last_update_date": DateTime.now(),
          "progress": ((completedHours / estimatedHours) * 100),
          "completed_hours": completedHours,
          "start_date": startDate,
          "target_completion_date": targetCompletionDate,
          "cost_code_id": editCostCode?.costCodeId,
        });

        return true;
      } else {
        await FirebaseAnalytics.instance.logEvent(name: 'add_new_cost_code');

        final doc = await _firestore.collection("costcodes").add({
          "code": code,
          "contractId": FirebaseFirestore.instance
              .collection("contracts")
              .doc(currentContract?.contractId ?? ""),
          "description": description,
          "estimated_hours": estimatedHours,
          "last_update_date": DateTime.now(),
          "progress": ((completedHours / estimatedHours) * 100),
          "completed_hours": completedHours,
          "added_hours": 0,
          "start_date": startDate,
          "created_date": DateTime.now(),
          "created_by":
              FirebaseFirestore.instance.collection("users").doc(user?.uid),
          "target_completion_date": targetCompletionDate,
        });
        doc.update({"cost_code_id": doc.id});
        return true;
      }
    } catch (e) {
      print("Error ${e}");
      return false;
    }
  }

  addNewTimeSheet({data}) async {
    try {
      final _firestore = FirebaseFirestore.instance;
      var doc = await _firestore.collection("timesheets").add(data);
      await doc.update({"timesheet_id": doc.id});
      return true;
    } catch (e, s) {
      print("Error Adding new Timesheet $e $s");
      return false;
    }
  }

  updateTimesheet({data, timesheetId}) async {
    try {
      final _firestore = FirebaseFirestore.instance;
      var doc = await _firestore
          .collection("timesheets")
          .doc(timesheetId)
          .update(data);
      return true;
    } catch (e, s) {
      print("Error updating the Timesheet $e $s");
      return false;
    }
  }

  // Future<bool> addNewTimeSheet(
  //     {required DateTime datePerformedOn,
  //     required timeSlots,
  //     required String contractId,
  //     required List<XFile> files,
  //     required double total}) async {
  //   final _firestore = FirebaseFirestore.instance;
  //   User? user = FirebaseAuth.instance.currentUser;
  //   final storageRef = FirebaseStorage.instance.ref();
  //   List<String> uploadedFilesUrls = [];
  //   try {
  //     await FirebaseAnalytics.instance.logEvent(name: 'add_new_timesheet');
  //
  //     for (XFile file in files) {
  //       var fileFile = File(file.path);
  //       final uploadTask = await storageRef
  //           .child("timesheets_files/${DateTime.now().millisecondsSinceEpoch}")
  //           .putFile(fileFile);
  //
  //       final String downloadUrl = await uploadTask.ref.getDownloadURL();
  //       uploadedFilesUrls.add(downloadUrl);
  //     }
  //
  //     var doc = await _firestore.collection("timesheets").add({
  //       "added_by":
  //           FirebaseFirestore.instance.collection("users").doc(user?.uid),
  //       "contract_id": FirebaseFirestore.instance
  //           .collection("contracts")
  //           .doc(currentContract?.contractId ?? ""),
  //       "created_at": DateTime.now(),
  //       "files": uploadedFilesUrls,
  //       "performed_on": datePerformedOn,
  //       "updated_at": DateTime.now(),
  //       "status": "pending",
  //     });
  //     doc.update({"timesheet_id": doc.id});
  //     print("contractId $contractId");
  //     List<DocumentReference> timeCards = [];
  //     for (TimeTableItem timeSlot in timeSlots) {
  //       double total = AppUtils.calculateTotalSlotToalTime(
  //           timeSlot.startTime ?? DateTime.now(),
  //           timeSlot.endTime ?? DateTime.now(),
  //           timeSlot.breakMins,
  //           timeSlot.breakHrs);
  //
  //       TimeCard card;
  //       if (timeSlot.worker != null) {
  //         card = TimeCard(
  //           startTime: Timestamp.fromDate(timeSlot.startTime ?? DateTime.now()),
  //           finishTime: Timestamp.fromDate(timeSlot.endTime ?? DateTime.now()),
  //           netHours: total,
  //           contract: FirebaseFirestore.instance
  //               .collection("contracts")
  //               .doc(contractId),
  //           crewId: null,
  //           worker: FirebaseFirestore.instance
  //               .collection("workers")
  //               .doc(timeSlot.worker?.workerId),
  //           timesheet: doc,
  //           breakTime:
  //               ((timeSlot.breakHrs * 60) + timeSlot.breakMins).toDouble(),
  //           costCode: FirebaseFirestore.instance
  //               .collection("costcodes")
  //               .doc(timeSlot.costCodeId),
  //         );
  //       } else {
  //         print("Adding crew ${timeSlot.crew?.crewId}");
  //         card = TimeCard(
  //           startTime: Timestamp.fromDate(timeSlot.startTime ?? DateTime.now()),
  //           finishTime: Timestamp.fromDate(timeSlot.endTime ?? DateTime.now()),
  //           netHours: total,
  //           contract: FirebaseFirestore.instance
  //               .collection("contracts")
  //               .doc(contractId),
  //           crewId: FirebaseFirestore.instance
  //               .collection("crews")
  //               .doc(timeSlot.crew?.crewId),
  //           worker: null,
  //           timesheet: doc,
  //           breakTime:
  //               ((timeSlot.breakHrs * 60) + timeSlot.breakMins).toDouble(),
  //           costCode: FirebaseFirestore.instance
  //               .collection("costcodes")
  //               .doc(timeSlot.costCodeId),
  //         );
  //       }
  //       var d = await _firestore.collection("workertimes").add(card.toJson());
  //       timeCards.add(d);
  //     }
  //
  //     await doc.update({"time_slots": timeCards});
  //
  //     await _firestore
  //         .collection("contracts")
  //         .doc(currentContract?.contractId)
  //         .update({"addedHours": FieldValue.increment(total)});
  //
  //     return true;
  //   } catch (e, s) {
  //     print("Could not add new Timesheet $e $s");
  //     return false;
  //   }
  // }

  Future<List<TimeSheet>> getTimeSheets({String? status}) async {
    try {
      final _firestore = FirebaseFirestore.instance;
      var docs;
      if (currentContract == null) {
        return [];
      }
      if (status != null) {
        docs = await _firestore
            .collection("timesheets")
            .where("contract",
                isEqualTo: FirebaseFirestore.instance
                    .collection("contracts")
                    .doc(currentContract?.contractId ?? ""))
            .where("status", isEqualTo: status)
            .get();
      } else {
        docs = await _firestore
            .collection("timesheets")
            .where("contract",
                isEqualTo: FirebaseFirestore.instance
                    .collection("contracts")
                    .doc(currentContract?.contractId ?? ""))
            .get();
      }
      List<TimeSheet> timeSheets = [];
      for (var doc in docs.docs) {
        var json = doc.data();
        timeSheets.add(TimeSheet.fromMap(json));
      }
      return timeSheets;
    } catch (e, s) {
      print("Could not get Timeshets $e $s");
      return [];
    }
  }

  Future<List<AppNotification?>> getNotifications({bool count = false}) async {
    final _firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;
    List<AppNotification> notifications = [];
    QuerySnapshot docs;

    print(currentContract?.contractId);
    print(">>>");
    print(user?.uid);

    docs = await _firestore
        .collection("notifications")
        .where("contract", isEqualTo: currentContract?.contractId ?? "")
        .where("receiver", isEqualTo: user?.uid)
        .get();

    for (QueryDocumentSnapshot doc in docs.docs) {
      Map<String, dynamic> json = (doc.data() ?? {}) as Map<String, dynamic>;
      notifications.add(AppNotification.fromJson(json));
      if (count == false) {
        doc.reference.update({"read": true});
      }
      notificationsCount = 0;
      notifyListeners();
    }

    return notifications;
  }

  Future<bool> createNewContract({
    isEdit = false,
    required String address,
    required String code,
    required String docId,
    required String projectNumber,
    required int approvedHours,
    required int currentProgress,
    required int estimatedHours,
    required String scopeOfWork,
    required String title,
    required String vendor,
    required String workLocation,
    required List<DocumentReference?>? contractors,
  }) async {
    final _firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;
    contractors = contractors?.where((e) => e != null).toList();

    try {
      if (isEdit) {
        await FirebaseAnalytics.instance.logEvent(name: 'edit_contract');

        await _firestore.collection("contracts").doc(docId).update({
          "address": address,
          "approvedHours": approvedHours,
          "code": code,
          "contractId": "",
          "createAt": DateTime.now(),
          "updatedAt": DateTime.now(),
          "contractors": contractors,
          "currentProgress": currentProgress,
          "estimatedHours": estimatedHours,
          "projectNumber": projectNumber,
          "scopeOfWork": scopeOfWork,
          "superIntendents": [
            FirebaseFirestore.instance.collection('users').doc(user?.uid)
          ],
          "title": title,
          "vendor": vendor,
          "contractStatus": "active",
          "workLocation": workLocation,
        });
      } else {
        await FirebaseAnalytics.instance.logEvent(name: 'create_new_contract');

        final doc = await _firestore.collection("contracts").add({
          "address": address,
          "approvedHours": approvedHours,
          "code": code,
          "contractId": "",
          "createAt": DateTime.now(),
          "updatedAt": DateTime.now(),
          "contractors": contractors,
          "currentProgress": currentProgress,
          "estimatedHours": estimatedHours,
          "projectNumber": projectNumber,
          "scopeOfWork": scopeOfWork,
          "superIntendents": [user?.uid],
          "title": title,
          "vendor": vendor,
          "contractStatus": "active",
          "workLocation": workLocation,
        });
        doc.update({"contractId": doc.id});
        for (DocumentReference? contractor in contractors ?? []) {
          if (contractor != null) {
            await contractor.update({
              "contracts": FieldValue.arrayUnion([doc.id]),
              "updated_at": DateTime.now()
            });
          }
        }
      }
      return true;
    } catch (e) {
      print("Error creating new Contract");
      return false;
    }
  }

  Future<List<AppUser>?> getAppContractors() async {
    try {
      final _firestore = FirebaseFirestore.instance;
      List<AppUser>? users = [];
      final docs = await _firestore.collection("users").get();
      for (var doc in docs.docs) {
        users.add(AppUser.fromJson(doc.data()));
      }
      return users;
    } catch (e, s) {
      print("Error getting users list $e $s");
      return [];
    }
  }

  isSuperIntendent() {
    return (currUserData?.role?.toLowerCase() == "superintendent" ||
        currUserData?.role?.toLowerCase() == "admin");
  }

  acceptTimeSheet(docId, contractId, double hours, sender, timeSlots) async {
    try {
      await FirebaseAnalytics.instance.logEvent(name: 'accept_timesheet');

      final _firestore = FirebaseFirestore.instance;

      var contractData = await contractId.get();

      for (TimeSlot slot in timeSlots) {
        var costCodeData =
            await _firestore.collection("costcodes").doc(slot.costCodeId).get();

        CostCode code =
            CostCode.fromJson(costCodeData.data() as Map<String, dynamic>);
        double costCodeNewProgress =
            (code.completedHours ?? 0 + hours) / (code.estimatedHours ?? 1);

        await _firestore.collection("costcodes").doc(slot.costCodeId).update({
          "completed_hours": FieldValue.increment(hours),
          "progress": costCodeNewProgress,
        });
      }

      Contract contract =
          Contract.fromJson(contractData.data() as Map<String, dynamic>);
      double newContractProgress = (contract.approvedHours ?? 0 + hours) /
          (contract.estimatedHours ?? 1);

      await _firestore
          .collection("timesheets")
          .doc(docId)
          .update({"status": "accepted"});

      await contractId.update({
        "approvedHours": FieldValue.increment(hours),
        "currentProgress": newContractProgress
      });

      await _firestore.collection("notifications").add({
        "dateSent": DateTime.now(),
        "notifyBackOffice": false,
        "read": false,
        "receiver": sender,
        "sender": currentUser?.uid,
        "statusChanged": "",
        "timesheet": docId,
        "contract": currentContract?.contractId,
        "title": "TimeSheet Approved",
        "description": "TimeSheet with ${hours} hours is Approved",
      });

      return true;
    } catch (e, s) {
      print("Error acceptTimeSheet $e $s");
      return false;
    }
  }

  rejectTimeSheet(docId, sender, hours) async {
    try {
      await FirebaseAnalytics.instance.logEvent(name: 'reject_timesheet');

      final _firestore = FirebaseFirestore.instance;
      await _firestore
          .collection("timesheets")
          .doc(docId)
          .update({"status": "pending", "resubmitted": true});

      await _firestore.collection("notifications").add({
        "dateSent": DateTime.now(),
        "notifyBackOffice": false,
        "read": false,
        "receiver": sender,
        "sender": currentUser?.uid,
        "statusChanged": "",
        "timesheet": docId,
        "contract": currentContract?.contractId,
        "title": "TimeSheet Rejected",
        "description": "TimeSheet with ${hours} hours is Rejected",
      });

      return true;
    } catch (e) {
      print("Error rejectTimeSheet $e");
      return false;
    }
  }

  Future<TimeSheet?> getTimeSheetById(String? timeSheetId) async {
    try {
      final _firestore = FirebaseFirestore.instance;

      var doc =
          await _firestore.collection("timesheets").doc(timeSheetId).get();
      var json = doc.data();

      TimeSheet timeSheet = TimeSheet.fromMap(json ?? {});

      return timeSheet;
    } catch (e, s) {
      print("Could not get Timeshet $e $s");
      return null;
    }
  }

  Future<bool> doesUserCompleteRegister() async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    User? user = firebaseAuth.currentUser;
    final _firestore = FirebaseFirestore.instance;

    var doc = await _firestore.collection("users").doc(user?.uid).get();
    if (doc.exists) {
      return true;
    }
    return false;
  }

  loadContractsDetails() async {
    List<Contract?> allContracts = [];

    var appUserData = currUserData;

    for (DocumentReference ref in appUserData?.contracts ?? []) {
      var data = await ref.get();
      if (data.exists) {
        Contract? contract =
            Contract.fromJson((data.data() ?? {}) as Map<String, dynamic>);
        allContracts.add(contract);
      }
    }
    if (currentContract == null && allContracts.isNotEmpty) {
      SharedPreferences prefs = GetIt.I.get();
      String? savedId =
          prefs.getString("current_contract_id") ?? allContracts[0]?.contractId;
      print("savedId $savedId");

      Contract? active = allContracts.firstWhere(
          (element) => element?.contractId == savedId,
          orElse: () => allContracts[0]);
      setCurrentContract(active);
    }
    setContracts(allContracts);
  }

  Future<List<AppComment>?> getTimeSheetComments(String timesheetId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("comments")
          .doc(timesheetId)
          .collection("timesheet_comments")
          .orderBy('added_at',
              descending:
                  false) // Set descending to true for sorting in descending order (latest first)
          .get();

      List<AppComment> comments = [];
      for (var doc in querySnapshot.docs) {
        comments.add(AppComment.fromJson(doc.data() as Map<String, dynamic>));
      }
      return comments;
    } catch (e) {
      print("Could not get timesheet Comments");
      return [];
    }
  }

  Future<String?> addNewVoiceComment(
      String outputFile, String timesheetId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final _firestore = FirebaseFirestore.instance;
      final storageRef = FirebaseStorage.instance.ref();
      File fileFile = File(outputFile);
      print("addNewVoiceRecordComment");

      final uploadTask = await storageRef
          .child("voice_records/${DateTime.now().millisecondsSinceEpoch}")
          .putFile(fileFile);

      final String downloadUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection("comments")
          .doc(timesheetId)
          .collection("timesheet_comments")
          .add({
        "added_by": _firestore.collection('users').doc(user?.uid),
        "added_at": Timestamp.now(),
        "type": "voice",
        "comment": downloadUrl,
        "contract": _firestore
            .collection('contracts')
            .doc(currentContract?.contractId ?? ""),
        "timesheet": _firestore.collection('timesheets').doc(timesheetId),
      });
      return downloadUrl;
    } catch (e) {
      print("Could not add new Comment");
      return null;
    }
  }

  addNewTextComment(String comment, String timesheetId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final _firestore = FirebaseFirestore.instance;

      await _firestore
          .collection("comments")
          .doc(timesheetId)
          .collection("timesheet_comments")
          .add({
        "added_by": _firestore.collection('users').doc(user?.uid),
        "added_at": Timestamp.now(),
        "type": "text",
        "comment": comment,
        "contract": _firestore
            .collection('contracts')
            .doc(currentContract?.contractId ?? ""),
        "timesheet": _firestore.collection('timesheets').doc(timesheetId),
      });
    } catch (e) {
      print("Could not add new Comment");
    }
  }

  getWorkerByRef(DocumentReference ref) async {
    var doc = await ref.get();
    Worker worker = Worker.fromJson(doc.data() as Map<String, dynamic>);
    return worker;
  }

  deleteCrew(String? crewId) async {
    try {
      final _firestore = FirebaseFirestore.instance;

      await _firestore.collection("crews").doc(crewId).update({
        "isActive": false,
      });
    } catch (e, s) {
      print("Could not delete the shift $e $s");
    }
  }

  setShitAsDefault(Shift? shift) async {
    if(shift !=null){
      try {
        final _firestore = FirebaseFirestore.instance;

        await _firestore.collection("contracts").doc(currentContract?.contractId).update({
          "defaultShift": _firestore.collection("shifts").doc(shift.shiftId),
          "defaultShiftId": shift.shiftId,
        });
        return true;
      } catch (e, s) {
        print("Could not delete the shift $e $s");
        return false;
      }
    }
    return false;
  }
  deleteShift(String? shiftId) async {
    try {
      final _firestore = FirebaseFirestore.instance;

      await _firestore.collection("shifts").doc(shiftId).update({
        "isActive": false,
      });
      print(" shiftId $shiftId");
    } catch (e, s) {
      print("Could not delete the shift $e $s");
    }
  }

  editShift({
    required int breakHrs,
    required String? shiftId,
    required int breakMins,
    required DateTime startTime,
    required DateTime endTime,
    required String shiftName,
  }) async {
    final _firestore = FirebaseFirestore.instance;
    try {
      await _firestore.collection("shifts").doc(shiftId).update({
        "breaks_mins": (breakHrs * 60) + breakMins,
        "end_time":
            "${endTime.hour}:${endTime.minute.toString().padLeft(2, "0")}",
        "start_time":
            "${startTime.hour}:${startTime.minute.toString().padLeft(2, "0")}",
        "shift_name": shiftName,
      });
    } catch (e, s) {
      print("Error Adding New Shift $e $s");
    }
  }

  addNewShift({
    required int breakHrs,
    required int breakMins,
    required DateTime startTime,
    required DateTime endTime,
    required String shiftName,
  }) async {
    final _firestore = FirebaseFirestore.instance;
    try {
      var doc = await _firestore.collection("shifts").add({
        "contract": FirebaseFirestore.instance
            .collection("contracts")
            .doc(currentContract?.contractId),
        "added_by": FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser?.uid),
        "breaks_mins": (breakHrs * 60) + breakMins,
        "added_at": Timestamp.now(),
        "end_time":
            "${endTime.hour}:${endTime.minute.toString().padLeft(2, "0")}",
        "start_time":
            "${startTime.hour}:${startTime.minute.toString().padLeft(2, "0")}",
        "isActive": true,
        "shift_name": shiftName,
      });
      await doc.update({
        "shift_id": doc.id,
      });
    } catch (e, s) {
      print("Error Adding New Shift $e $s");
    }
  }

  Future<List<Shift>> getContractShifts() async {
    final _firestore = FirebaseFirestore.instance;
    List<Shift> shifts = [];

    final docs = await _firestore
        .collection("shifts")
        .where("contract",
            isEqualTo: FirebaseFirestore.instance
                .collection("contracts")
                .doc(currentContract?.contractId))
        .where("isActive", isEqualTo: true)
        .get();
    for (var doc in docs.docs) {
      Shift shift = Shift.fromJson(doc.data());
      print("shift ${shift.shiftId}");
      shifts.add(shift);
    }
    setShifts(shifts);

    return shifts;
  }

  deleteFileFromTimesheet(String? timesheetId, String? fileUrl) async {
    try {
      if (timesheetId == null || fileUrl == null) {
        return;
      }
      // Replace 'yourCollection' with the actual name of your collection
      CollectionReference<Map<String, dynamic>> collectionReference =
          FirebaseFirestore.instance.collection('timesheets');

      // Get the document reference
      DocumentReference<Map<String, dynamic>> documentReference =
          collectionReference.doc(timesheetId);

      // Get the current data in the document
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await documentReference.get();

      // Check if the document exists
      if (documentSnapshot.exists) {
        // Get the current list of files
        List<dynamic> files = documentSnapshot.data()?['files'] ?? [];

        // Remove the specified URL from the list
        files.remove(fileUrl);

        // Update the document with the modified list
        await documentReference.update({'files': files});
        print('URL removed successfully.');
      } else {
        print('Document does not exist.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}

class LoginInfo {
  final bool isLoggedIn;

  LoginInfo(this.isLoggedIn);
}
