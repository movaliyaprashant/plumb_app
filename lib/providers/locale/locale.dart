import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:plumbata/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../base.dart';
import 'language.dart';

class LocaleProvider extends BaseChangeNotifier {
  AppLanguage _selectedLanguage = AppLanguage.english();
  late Locale _selectedLocal;

  final List<AppLanguage> supportedLanguages = [
    AppLanguage.english(),
  ];

  LocaleProvider() {
    init();
  }

  init() {
    SharedPreferences prefs = GetIt.I.get();
    var langCode = prefs.getString('LANG');
    if(langCode == null){
      prefs.setString('LANG', 'fr');
      _selectedLocal = Locale.fromSubtags(languageCode: "fr");
      langCode = 'fr';
    }
    _selectedLanguage = supportedLanguages.firstWhere(
          (lang) => lang.languageCode == langCode,
      orElse: () => AppLanguage.english(),
    );
    _selectedLocal =  Locale.fromSubtags(languageCode: _selectedLanguage.languageCode);
    Intl.defaultLocale = langCode;

    S.load(Locale(langCode!));
    notifyListeners();

  }

  void changeLanguage(AppLanguage language) {
    SharedPreferences prefs = GetIt.I.get();
    prefs.setString('LANG', language.languageCode);
    prefs.setBool('LANG_SET', true);
    _selectedLanguage = language;
    Intl.defaultLocale = language.languageCode;
    S.load(Locale(language.languageCode));
    notifyListeners();
  }
  bool didLanguageInit() {
    SharedPreferences prefs = GetIt.I.get();
    bool? set = prefs.getBool('LANG_SET')??false;
    return set;
  }

  setLocal(languageCode){
    _selectedLocal = Locale.fromSubtags(languageCode: languageCode);
    notifyListeners();
  }
  Locale get selectedLocal =>  _selectedLocal;

  AppLanguage get selectedLanguage => _selectedLanguage;
}
