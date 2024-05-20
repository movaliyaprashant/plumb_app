
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:plumbata/app/plumbata.dart';
import 'package:plumbata/firebase_options.dart';
import 'package:plumbata/manager/auth_manager.dart';
import 'package:plumbata/manager/auth_manager_impl.dart';
import 'package:plumbata/net/api_executor.dart';
import 'package:plumbata/net/api_executor_impl.dart';
import 'package:plumbata/repo/auth/auth_repo.dart';
import 'package:plumbata/repo/auth/auth_repo_impl.dart';
import 'package:plumbata/services/connectivity/connectivity_impl.dart';
import 'package:plumbata/services/connectivity/connectivity_interface.dart';
import 'package:plumbata/services/files/files_impl.dart';
import 'package:plumbata/services/files/files_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:firebase_analytics/firebase_analytics.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  bool shouldUseFirestoreEmulator = false;


   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
  );


  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;


  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    statusBarIconBrightness: Brightness.light,
    statusBarColor: Colors.black,
  ));

  SharedPreferences prefs = await SharedPreferences.getInstance();

  //Get logged user
  User? user = FirebaseAuth.instance.currentUser;

  _setup(prefs, user);

  runApp(
    PlumbataApp(),
  );
}

void _setup(SharedPreferences prefs, User? user) {
  final getIt = GetIt.instance;

  getIt.registerLazySingleton<AuthManager>(() => AuthManagerImpl());

  getIt.registerLazySingleton<ApiExecutor>(() => ApiExecutorImpl());

  getIt.registerLazySingleton<AuthRepo>(() => AuthRepoImpl());

  getIt.registerLazySingleton<ConnectivityService>(
          () => ConnectivityServiceImpl());

  getIt.registerLazySingleton<SharedPreferences>(() => prefs);

  getIt.registerLazySingleton<FilesServices>(() => FilesServiceImpl());
}
