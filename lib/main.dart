import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'database/database_helper.dart';
import 'screens/accueil/accueil_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise les données de date pour le français
  await initializeDateFormatting('fr_FR', null);
  await DatabaseHelper.instance.database;
  runApp(const SmartAgendaApp());
}

class SmartAgendaApp extends StatelessWidget {
  const SmartAgendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'SmartAgenda',

      // Langue française
      locale: const Locale('fr', 'FR'),

      // Localisations Flutter
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Langues supportées
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
      ),

      home: const AccueilPage(),
    );
  }
}