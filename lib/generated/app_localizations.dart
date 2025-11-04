// GENERATED CODE - DO NOT MODIFY BY HAND
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_he.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('he')
  ];

  String get appName;
  String get welcome;
  String get start;
  String get next;
  String get back;
  String get correct;
  String get tryAgain;
  String get wellDone;
  String get awesome;
  String get great;
  String get modules;
  String get numbers;
  String get letters;
  String get colors;
  String get shapes;
  String get numbersTitle;
  String get numbersDescription;
  String get learnMode;
  String get quizMode;
  String get numberOne;
  String get numberTwo;
  String get numberThree;
  String get numberFour;
  String get numberFive;
  String get numberSix;
  String get numberSeven;
  String get numberEight;
  String get numberNine;
  String get numberTen;
  String get colorsTitle;
  String get colorsDescription;
  String get shapesTitle;
  String get shapesDescription;
  String get lettersTitle;
  String get lettersDescription;
  String get settings;
  String get language;
  String get english;
  String get hebrew;
  String get sound;
  String get soundOn;
  String get soundOff;
  String get music;
  String get musicOn;
  String get musicOff;
  String get progress;
  String get completed;
  String get inProgress;
  String get stars;
  String get score;
  String get question;
  String get howMany;
  String get playAgain;
  String get comingSoon;
  String get colorRed;
  String get colorBlue;
  String get colorYellow;
  String get colorGreen;
  String get colorOrange;
  String get colorPurple;
  String get colorPink;
  String get colorBrown;
  String get colorBlack;
  String get colorWhite;
  String selectTheColor(String color);
  String get whichColor;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'he'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'he': return AppLocalizationsHe();
  }
  throw FlutterError('AppLocalizations.delegate failed to load unsupported locale');
}
