import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shotify_frontend/screens/main_screen.dart';
import 'package:shotify_frontend/services/photo_provider.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if(kIsWeb)
  {await Firebase.initializeApp(options: const FirebaseOptions(apiKey: "AIzaSyB8t58GCpgdmf4viTAfoiWtA1fStIFzMwE",
      authDomain: "shotify-d5ae8.firebaseapp.com",
      projectId: "shotify-d5ae8",
      storageBucket: "shotify-d5ae8.firebasestorage.app",
      messagingSenderId: "402660941765",
      appId: "1:402660941765:web:39cd77605645cfdf64f5ac",
      measurementId: "G-2FQJ55RK2W"));}
  else{
    await Firebase.initializeApp();
  }

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => PhotoProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme(bool isDarkMode) {
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: MainScreen(
        onThemeChanged: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}
