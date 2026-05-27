import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'view/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(DevicePreview(enabled: !kReleaseMode, builder: (context) => const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void toggleTheme(BuildContext context) {
    context.findAncestorStateOfType<_MyAppState>()?.toggleTheme();
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Finanças',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF86EFAC),
          secondary: Color(0xFF4ADE80),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF133E28),
          foregroundColor: Color(0xFF86EFAC),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF86EFAC),
          foregroundColor: Color(0xFF133E28),
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: LoginView(isDarkMode: _isDarkMode, onToggleTheme: toggleTheme),
      debugShowCheckedModeBanner: false,
      locale: kReleaseMode ? null : DevicePreview.locale(context),
      builder: kReleaseMode ? null : DevicePreview.appBuilder,
    );
  }
}
