import 'package:flutter/material.dart';
import 'package:shotify_frontend/screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shotify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        //'/history': (context) => HistoryScreen(),
        //'/settings': (context) => SettingsScreen(),
      },
    );
  }
}
