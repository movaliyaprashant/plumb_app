import 'package:flutter/material.dart';
import 'package:plumbata/utils/style.dart';
import 'package:shared_preferences/shared_preferences.dart';


const Themes _defaultTheme = Themes.system;

enum Themes { light, dark, system }

/// Saves and loads information regarding the theme setting.
class ThemeProvider with ChangeNotifier {
  static Themes _theme = _defaultTheme;

  ThemeProvider() {
    init();
  }

  Themes get theme => _theme;

  set theme(Themes theme) {
    _theme = theme;
    notifyListeners();
  }

  /// Returns appropriate theme mode.
  ThemeMode get themeMode {
    switch (_theme) {
      case Themes.light:
        return ThemeMode.light;
      case Themes.dark:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  bool isDarkMode(){
    return _theme == Themes.dark;
  }



  /// Default light theme
  ThemeData lightTheme(context) => Style().light(context);

  /// Default dark theme
  ThemeData darkTheme(context) => Style().dark(context);

  /// Load theme information from local storage
  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? activeTheme = prefs.getString("ACTIVE_THEME");
    if(activeTheme == 'dark'){
      setDarkTheme();
      saveTheme(isDark: true);
    }else{
      setLightTheme();
      saveTheme(isDark: false);
    }
  }

  saveTheme({required bool isDark}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("ACTIVE_THEME", isDark ? "dark" : "light");
  }


  ThemeData getThemeData(context) {
    switch (_theme) {
      case Themes.light:
        return lightTheme(context);
      case Themes.dark:
        return darkTheme(context);
      default:
        return lightTheme(context);
    }
  }
  setDarkTheme(){
    _theme = Themes.dark;
    saveTheme(isDark: true);
    notifyListeners();
  }

  setLightTheme(){
    _theme = Themes.light;
    saveTheme(isDark: false);
    notifyListeners();
  }
}
