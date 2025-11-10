import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// מנהל את מצב האפליקציה: שפה, הגדרות קול, והתקדמות
class AppProvider with ChangeNotifier {
  Locale _locale = const Locale('he'); // ברירת מחדל: עברית
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  final FlutterTts _flutterTts = FlutterTts();

  // התקדמות למודולים - כל 14 המודולים
  Map<String, ModuleProgress> _progress = {
    // מיומנויות בסיסיות
    'numbers': ModuleProgress(),
    'letters': ModuleProgress(),
    'colors': ModuleProgress(),
    'shapes': ModuleProgress(),

    // העולם סביבנו
    'animals': ModuleProgress(),
    'vehicles': ModuleProgress(),
    'weather': ModuleProgress(),
    'fruits_vegetables': ModuleProgress(),
    'body_parts': ModuleProgress(),

    // אנשים ורגשות
    'family': ModuleProgress(),
    'emotions': ModuleProgress(),
    'professions': ModuleProgress(),

    // יצירתי ומהנה
    'music': ModuleProgress(),
    'drawing': ModuleProgress(),
  };

  // Getters
  Locale get locale => _locale;
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  Map<String, ModuleProgress> get progress => _progress;

  int get totalStars => _progress.values
      .fold(0, (sum, module) => sum + module.stars);

  AppProvider() {
    _loadPreferences();
  }

  /// טען הגדרות מ-SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // טען שפה
    final String? savedLang = prefs.getString('language');
    if (savedLang != null) {
      _locale = Locale(savedLang);
    }

    // טען הגדרות קול
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    _musicEnabled = prefs.getBool('musicEnabled') ?? true;

    // טען התקדמות
    _progress.forEach((key, value) {
      value.stars = prefs.getInt('${key}_stars') ?? 0;
      value.completed = prefs.getBool('${key}_completed') ?? false;
      value.correctAnswers = prefs.getInt('${key}_correct') ?? 0;
      value.totalAttempts = prefs.getInt('${key}_attempts') ?? 0;
    });

    // קבע TTS אחרי שטענו את השפה
    await _configureTts();

    notifyListeners();
  }

  /// קבע הגדרות TTS
  Future<void> _configureTts() async {
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.4); // קצב איטי יותר לילדים
    await _flutterTts.setPitch(1.1); // טון מעט גבוה יותר - ידידותי יותר
    await _flutterTts.awaitSpeakCompletion(true); // חכה עד שהדיבור מסתיים

    // קבע שפה התחלתית
    await _flutterTts.setLanguage(
      _locale.languageCode == 'he' ? 'he-IL' : 'en-US'
    );
  }

  /// שנה שפה
  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;

    _locale = newLocale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', newLocale.languageCode);

    // עדכן שפת TTS
    await _flutterTts.setLanguage(
      newLocale.languageCode == 'he' ? 'he-IL' : 'en-US'
    );

    notifyListeners();
  }

  /// הפעל/כבה קול
  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', _soundEnabled);

    if (!_soundEnabled) {
      await _flutterTts.stop();
    }

    notifyListeners();
  }

  /// הפעל/כבה מוזיקה
  Future<void> toggleMusic() async {
    _musicEnabled = !_musicEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('musicEnabled', _musicEnabled);
    notifyListeners();
  }

  /// דבר טקסט
  Future<void> speak(String text) async {
    if (!_soundEnabled) return;

    // עצור את הדיבור הקודם
    await _flutterTts.stop();

    // המתן רגע קצר לפני תחילת דיבור חדש
    await Future.delayed(const Duration(milliseconds: 100));

    await _flutterTts.speak(text);
  }

  /// הוסף כוכב למודול
  Future<void> addStar(String module) async {
    if (!_progress.containsKey(module)) return;

    _progress[module]!.stars++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${module}_stars', _progress[module]!.stars);
    notifyListeners();
  }

  /// רשום תשובה (נכונה או לא)
  Future<void> recordAnswer(String module, bool isCorrect) async {
    if (!_progress.containsKey(module)) return;

    _progress[module]!.totalAttempts++;
    if (isCorrect) {
      _progress[module]!.correctAnswers++;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${module}_correct', _progress[module]!.correctAnswers);
    await prefs.setInt('${module}_attempts', _progress[module]!.totalAttempts);
    notifyListeners();
  }

  /// סמן מודול כהושלם
  Future<void> markModuleCompleted(String module) async {
    if (!_progress.containsKey(module)) return;

    _progress[module]!.completed = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${module}_completed', true);
    notifyListeners();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}

/// מודל התקדמות למודול
class ModuleProgress {
  int stars;
  bool completed;
  int correctAnswers;
  int totalAttempts;

  ModuleProgress({
    this.stars = 0,
    this.completed = false,
    this.correctAnswers = 0,
    this.totalAttempts = 0,
  });

  double get accuracy =>
      totalAttempts > 0 ? correctAnswers / totalAttempts : 0.0;
}
