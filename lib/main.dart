import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/home_screen.dart';
import 'core/progress_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize any persistent storage or services here
  runApp(const LearningFunApp());
}

class LearningFunApp extends StatelessWidget {
  const LearningFunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProgressProvider(),
      child: MaterialApp(
        title: 'לומדים בכיף',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Roboto',
        ),
        supportedLocales: const [Locale('he'), Locale('en')],
        home: const HomeScreen(),
      ),
    );
  }
}
