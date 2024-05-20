import 'package:flutter/material.dart';

import 'colors.dart';
import 'fonts.dart';
/// Class that contains all the different styles of an app
class Style {
  //TODO add styles
  TextTheme appTextTheme(context) => TextTheme(
    bodySmall: TextStyle(
        debugLabel: 'app overline',
        fontFamily: kOpenSansFont,
        inherit: true,
        color: AppColors.lightBodyTextColor,
        decoration: TextDecoration.none,
        fontSize: 12),

    titleMedium: TextStyle(
        color: AppColors.lightBodyTextColor,
        fontSize: MediaQuery.of(context).size.width > 451 ? 26 : 22,
        fontFamily: kOpenSansFont,
        fontWeight: FontWeight.w600),
    titleSmall: TextStyle(
        color: AppColors.darkBodyTextColor,
        fontSize: MediaQuery.of(context).size.width > 451 ? 22 : 18,
        fontFamily: kOpenSansFont,
        fontWeight: FontWeight.w300),


    bodyMedium: TextStyle(
        debugLabel: 'app overline',
        fontFamily: kOpenSansFont,
        inherit: true,
        color: AppColors.lightBodyTextColor,
        decoration: TextDecoration.none,
        fontSize: MediaQuery.of(context).size.width > 451 ? 20 : 16),
    bodyLarge: TextStyle(
        debugLabel: 'app overline',
        fontFamily: kOpenSansFont,
        inherit: true,
        fontWeight: FontWeight.w600,
        color: AppColors.lightBodyTextColor,
        decoration: TextDecoration.none,
        fontSize: MediaQuery.of(context).size.width > 500 ? 24 : 22),
  );

  //2021
  // displayLarge, displayMedium, displaySmall
  // headlineLarge, headlineMedium, headlineSmall
  // titleLarge, titleMedium, titleSmall
  // bodyLarge, bodyMedium, bodySmall
  // labelLarge, labelMedium, labelSmall

  /// Dark Style
  TextTheme darkTextTheme(context) => TextTheme(
    bodyMedium: TextStyle(
        debugLabel: 'app overline',
        fontFamily: kOpenSansFont,
        inherit: true,
        color: AppColors.darkBodyTextColor,
        decoration: TextDecoration.none,
        fontSize: MediaQuery.of(context).size.width > 500 ? 20 : 18),
    titleSmall: TextStyle(
        color: AppColors.darkBodyTextColor,
        fontSize: MediaQuery.of(context).size.width > 500 ? 22 : 18,
        fontFamily: kOpenSansFont,
        fontWeight: FontWeight.w300),
    titleMedium: TextStyle(
        color: AppColors.darkBodyTextColor,
        fontSize: MediaQuery.of(context).size.width > 500 ? 28 : 24,
        fontFamily: kOpenSansFont,
        fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(
        debugLabel: 'app overline',
        fontFamily: kOpenSansFont,
        inherit: true,
        color: AppColors.darkBodyTextColor,
        decoration: TextDecoration.none,
        fontWeight: FontWeight.w600,
        fontSize: MediaQuery.of(context).size.width > 500 ? 28 : 22),
  );

  /// Light style
  ThemeData light(context) => ThemeData(
    fontFamily: kOpenSansFont,
    brightness: Brightness.light,
    primaryColor: AppColors.lightPrimaryColor,
    hintColor: AppColors.lightAccentColor,
    pageTransitionsTheme: _pageTransitionsTheme,
    indicatorColor: AppColors.lightIndicatorColor,
    scaffoldBackgroundColor: Colors.white,
    canvasColor: AppColors.lightCanvasColor,
    hoverColor: AppColors.lightSurfaceColor,
    shadowColor: Colors.grey[300],
    textTheme: appTextTheme(context),
    dividerTheme: DividerThemeData(
        color: AppColors.lightDividerColor, thickness: 1.1),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.lightPrimaryColor,
    ),
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
        BorderSide(color: AppColors.filedBorder, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
        BorderSide(color: AppColors.filedBorder, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderSide:
        BorderSide(color: AppColors.filedBorder, width: 1),
        borderRadius: BorderRadius.circular(14),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: const BorderSide(color: Color(0xffeeeeee), width: 3),
        borderRadius: BorderRadius.circular(14),
      ),
      filled: true,
      fillColor: Colors.white,
      iconColor: const Color(0xff999999),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: kOpenSansFont,
        color: Color(0xff9da4bb),
      ),
      hintStyle: const TextStyle(
        fontSize: 14,
        fontFamily: kOpenSansFont,
        color: Color(0xff9da4bb),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    ),
  );

  /// Custom page transitions
  static const _pageTransitionsTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  );

  ///Dark theme
  ThemeData dark(context) => ThemeData(
    fontFamily: kOpenSansFont,
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimaryColor,
    hintColor: AppColors.darkAccentColor,
    pageTransitionsTheme: _pageTransitionsTheme,
    indicatorColor: AppColors.darkIndicatorColor,
    scaffoldBackgroundColor: AppColors.darkBackgroundColor,
    canvasColor: AppColors.darkCanvasColor,
    hoverColor: AppColors.darkSurfaceColor,
    shadowColor: Colors.grey[800],
    textTheme: darkTextTheme(context),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkDividerColor,
      thickness: 1.1,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.darkPrimaryColor,
    ),
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.darkPrimaryColor,
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.darkPrimaryColor,
          width: 1,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderSide:  BorderSide(
          color: AppColors.darkErrorColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: const BorderSide(
          color: Color(0xffeeeeee),
          width: 3,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      filled: true,
      fillColor: Colors.black,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 20,
      ),
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: kOpenSansFont,
        color: Color(0xff9da4bb),
      ),
      iconColor: const Color(0xffffffff),
      focusColor: const Color(0xffffffff),
      hintStyle: const TextStyle(
        fontSize: 14,
        fontFamily: kOpenSansFont,
        color: Color(0xff9da4bb),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    ),
  );
}
