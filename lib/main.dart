import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/database_config.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const IkirahaApp());
}

class IkirahaApp extends StatelessWidget {
  const IkirahaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: DatabaseConfig.appName,
        debugShowCheckedModeBanner: false,

        // Localization
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English
          Locale('fr', ''), // French
          Locale('es', ''), // Spanish
          Locale('rw', ''), // Kinyarwanda
          Locale('sw', ''), // Swahili
        ],

        // Theme
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32), // Green theme for food app
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),

        // Dark Theme
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),

        home: const SplashScreen(),
    );
  }
}


