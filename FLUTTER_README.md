# 🎮 לומדים בכיף - אפליקציה חינוכית דו-לשונית לילדים

אפליקציית Flutter אינטראקטיבית לילדים בגילאי 2-6, עם תמיכה מלאה בעברית ואנגלית ומודולי למידה מהנים למספרים, אותיות, צבעים וצורות.

## ✨ תכונות

### 🌐 תמיכה דו-לשונית
- **עברית ↔ אנגלית** עם תמיכה מלאה ב-RTL
- החלפת שפה בזמן אמת
- קריינות בשתי השפות עם flutter_tts

### 📚 מודולי למידה
- **מודול מספרים** (MVP - מיושם במלואו)
  - מצב למידה: למידת מספרים ויזואלית עם ייצוג נקודות
  - מצב חידון: משחק זיהוי מספרים אינטראקטיבי
  - קריינות בשפה הנבחרת
  - מעקב התקדמות עם מערכת כוכבים

- **בקרוב:**
  - מודול אותיות
  - מודול צבעים
  - מודול צורות

### 🎨 עיצוב ידידותי לילדים
- כפתורים גדולים וצבעוניים (מינימום 80px לנגיעה)
- אנימציות חלקות
- פינות מעוגלות וגרדיאנטים משחקיים
- פונטים ידידותיים
- משוב מעודד ואנימציות פרס

### 🎵 תכונות אודיו
- אפקטי קול לאינטראקציות
- סינתזת דיבור (TTS) לתוכן למידה
- בקרות השתקה בהגדרות
- מתגים נפרדים למוזיקה/קול

### 📊 מעקב התקדמות
- מערכת פרסים מבוססת כוכבים
- מעקב השלמת מודולים
- סטטיסטיקות בהגדרות
- שמירה מקומית עם SharedPreferences

## 🛠 סטאק טכנולוגי

- **Framework:** Flutter 3.x
- **State Management:** Provider
- **Localization:** flutter_localizations + ARB files
- **Text-to-Speech:** flutter_tts
- **Storage:** shared_preferences
- **Animations:** Flutter AnimationController
- **Audio:** flame_audio (אופציונלי)
- **Animations:** lottie (אופציונלי)

## 📁 מבנה הפרויקט

```
lib/
├── l10n/                           # קבצי תרגום
│   ├── app_en.arb                  # תרגום אנגלית
│   └── app_he.arb                  # תרגום עברית
├── providers/                      # ניהול state
│   └── app_provider.dart           # Provider ראשי
├── widgets/                        # ווידג'טים משותפים
│   ├── kid_button.dart             # כפתור מותאם לילדים
│   ├── language_toggle.dart        # החלפת שפה
│   └── reward_animation.dart       # אנימציית פרס
├── modules/                        # מודולי למידה
│   └── numbers/
│       ├── numbers_learning_screen.dart
│       ├── numbers_quiz_screen.dart
│       └── numbers_menu_screen.dart
├── screens/                        # מסכים ראשיים
│   ├── new_home_screen.dart        # מסך הבית
│   └── settings_screen.dart        # מסך הגדרות
├── main.dart                       # נקודת כניסה
└── [תיקיות ישנות לתאימות לאחור]
    ├── ui/
    ├── core/
    └── games/
```

## 🚀 התחלה מהירה

### דרישות מקדימות
- Flutter SDK 3.0+
- Dart SDK 3.0+
- טאבלט/אמולטור Android/iOS

### התקנה והרצה

1. **שכפל את הריפוזיטורי (אם עדיין לא):**
   ```bash
   git clone <repository-url>
   cd learning-games
   ```

2. **התקן dependencies:**
   ```bash
   flutter pub get
   ```

3. **הרץ code generation ללוקליזציה:**
   ```bash
   flutter gen-l10n
   ```

4. **הרץ את האפליקציה:**
   ```bash
   flutter run
   ```

   או על מכשיר ספציפי:
   ```bash
   flutter devices              # ראה רשימת מכשירים
   flutter run -d <device-id>   # הרץ על מכשיר מסוים
   ```

### בנייה לפרודקשן

**Android (APK):**
```bash
flutter build apk --release
```

**Android (App Bundle):**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

הקבצים יהיו ב:
- Android: `build/app/outputs/flutter-apk/`
- iOS: `build/ios/iphoneos/`

## 🎯 שימוש

### ניווט
- **מסך הבית:** בחר מודול למידה
- **מודול מספרים:** בחר בין מצב למידה או חידון
- **הגדרות:** קבע שפה, קול והצג התקדמות
- **החלפת שפה:** לחץ על הדגל (למעלה מימין) להחלפת שפות

### מצב למידה
1. לחץ על כרטיס מודול (לדוגמה: מספרים)
2. בחר "מצב למידה"
3. צפה במספרים עם ייצוג ויזואלי
4. לחץ על סמל הרמקול לשמיעת ההגייה
5. השתמש בכפתורי הבא/קודם לניווט

### מצב חידון
1. לחץ על כרטיס מודול
2. בחר "זמן חידון"
3. ספור את הנקודות ובחר את המספר הנכון
4. צבור כוכבים על תשובות נכונות
5. השלם 5 שאלות לסיום

## 🔧 הגדרות ותצורה

### הוספת שפות נוספות
1. צור קובץ תרגום חדש `lib/l10n/app_<lang>.arb`
2. עדכן `l10n.yaml` אם נדרש
3. הוסף את השפה ל-`supportedLocales` ב-`main.dart`
4. הרץ `flutter gen-l10n`

### הוספת מודולים חדשים
1. צור תיקייה חדשה `lib/modules/{module-name}/`
2. יישם מסכי Learning ו-Quiz
3. הוסף תרגומים ל-ARB files
4. עדכן את מסך הבית עם כרטיס מודול חדש
5. עדכן `AppProvider` במידת הצורך

## 📱 תאימות

### נבדק על:
- ✅ Android 6.0+ (API level 23+)
- ✅ iOS 12.0+
- ✅ טאבלטים (מותאם למסכים גדולים)
- ⚠️ Web (פונקציונלי אך עדיין לא אופטימלי)

### אוריינטציה:
- תומך ב-portrait ו-landscape
- UI מתאים אוטומטית לגודל מסך

## 🐛 בעיות ידועות ושיפורים עתידיים

### מגבלות נוכחיות
- רק מודול מספרים מיושם במלואו
- קבצי אודיו הם placeholders (משתמש ב-TTS)
- אין אינטגרציית backend (כל הנתונים נשמרים מקומית)
- הקבצים הישנים (`ui/`, `core/`, `games/`) עדיין קיימים לתאימות

### תכונות מתוכננות
- [ ] השלמת מודולים: אותיות, צבעים, צורות
- [ ] הוספת קבצי אודיו מותאמים אישית
- [ ] סוגי חידונים נוספים (גרור ושחרר)
- [ ] לוח מחוונים להורים עם אנליטיקס מפורט
- [ ] API backend לסינכרון התקדמות בענן
- [ ] תמיכה בשפות נוספות
- [ ] מצב offline עם service workers
- [ ] מערכת תעודות/הישגים
- [ ] מוזיקת רקע

## 📝 איכות קוד

### Dart/Flutter Best Practices
- ✅ Null safety מופעל
- ✅ הפרדת concerns (Provider, Widgets, Screens)
- ✅ תיעוד ברור עם הערות בעברית ואנגלית
- ✅ שימוש ב-const constructors לביצועים
- ✅ ניהול state מרכזי עם Provider

### ארכיטקטורה
- MVVM pattern
- Repository pattern (לעתיד)
- Clean Architecture principles

## 🔄 עדכונים אחרונים

### גרסה 0.1.0 (נובמבר 2025)
- ✅ מערכת לוקליזציה מלאה (עברית + אנגלית)
- ✅ מודול מספרים מלא
- ✅ מערכת state management עם Provider
- ✅ TTS לקריינות
- ✅ מסך הגדרות עם בקרות
- ✅ אנימציות ופרסים
- ✅ שמירה מקומית

## 🤝 תרומה

תרומות יתקבלו בברכה! אנא עקוב אחר השלבים הבאים:
1. Fork את הריפוזיטורי
2. צור branch לפיצ'ר
3. בצע את השינויים שלך
4. בדוק ביסודיות
5. שלח pull request

### הנחיות קוד
- הוסף הערות בעברית ואנגלית
- שמור על עקביות עם הסגנון הקיים
- בדוק שהקוד עובד על Android ו-iOS
- הוסף תרגומים לשתי השפות

## 📄 רישיון

חלק מפרויקט learning-games.

## 🙏 קרדיטים

- **Fonts:** ברירת מחדל של Flutter + Google Fonts (עתידי)
- **Icons:** Emoji (cross-platform compatible)
- **Audio:** flutter_tts + flame_audio
- **Animations:** Flutter built-in animations + Lottie

---

## 📚 משאבים נוספים

### למידה
- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [Internationalization Guide](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)

### כלים
```bash
# בדיקת בריאות הפרויקט
flutter doctor -v

# ניתוח קוד
flutter analyze

# בדיקות
flutter test

# ניקוי build
flutter clean
flutter pub get
```

---

🎈 **נבנה באהבה ללומדים הצעירים שלנו!** 🎈
