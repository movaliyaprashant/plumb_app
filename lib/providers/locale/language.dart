import 'package:flutter/material.dart';

class AppLanguage {
  final String displayTitle;
  final String languageCode;

  AppLanguage({
    required this.displayTitle,
    required this.languageCode,
  });

  factory AppLanguage.french() =>
      AppLanguage(languageCode: "fr", displayTitle: 'French');

  factory AppLanguage.english() =>
      AppLanguage(languageCode: "en", displayTitle: 'English');

  Locale get locale => Locale.fromSubtags(languageCode: languageCode);

  TextDirection get textDirection {
    if (languageCode == 'ar' || languageCode == 'he') {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }
}
