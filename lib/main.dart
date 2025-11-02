import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:learning_fun/generated/app_localizations.dart';
import 'providers/app_provider.dart';
import 'screens/new_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LearningFunApp());
}

class LearningFunApp extends StatelessWidget {
  const LearningFunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return MaterialApp(
            title: 'לומדים בכיף - Learning Fun',
            debugShowCheckedModeBanner: false,

            // תמיכה בלוקליזציה
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // אנגלית
              Locale('he'), // עברית
            ],

            // שפה נוכחית
            locale: appProvider.locale,

            // תמיכה ב-RTL לעברית
            builder: (context, child) {
              return Directionality(
                textDirection: appProvider.locale.languageCode == 'he'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: child!,
              );
            },

            // ערכת נושא
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.orange,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              fontFamily: appProvider.locale.languageCode == 'he'
                  ? 'Rubik' // פונט ידידותי לעברית
                  : 'Quicksand', // פונט ידידותי לאנגלית
              textTheme: const TextTheme(
                displayLarge: TextStyle(
                  fontSize: 96,
                  fontWeight: FontWeight.bold,
                ),
                displayMedium: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                ),
                displaySmall: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
                headlineLarge: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
                headlineMedium: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
                headlineSmall: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                titleLarge: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
                bodyLarge: TextStyle(fontSize: 18),
                bodyMedium: TextStyle(fontSize: 16),
              ),
            ),

            home: const NewHomeScreen(),
          );
        },
      ),
    );
  }
}
