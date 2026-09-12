import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app_localizations.dart';
import 'app_settings.dart';
import 'database/database_helper.dart';
import 'services/notification_service.dart';
import 'views/accueil/accueil_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('fr_FR', null);
  await DatabaseHelper.instance.database;
  await NotificationService.instance.initialize();

  final appSettings = AppSettings();
  await appSettings.load();

  runApp(
    SmartAgendaApp(
      appSettings: appSettings,
    ),
  );
}

class SmartAgendaApp extends StatelessWidget {
  final AppSettings appSettings;

  const SmartAgendaApp({
    super.key,
    required this.appSettings,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          title: 'SmartAgenda',

          locale: Locale(
  appSettings.parametres.langue,
  appSettings.parametres.langue == 'fr'
      ? 'FR'
      : appSettings.parametres.langue == 'en'
      ? 'US'
      : 'TN',
),

          localizationsDelegates: const [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],

          supportedLocales: const [
            Locale('fr', 'FR'),
            Locale('en', 'US'),
            Locale('ar', 'TN'),
          ],

          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Arial',
            colorScheme: ColorScheme.fromSeed(
              seedColor: appSettings.themeColor,
            ),
          ),

          home: AccueilPage(
  appSettings: appSettings,
),
        );
      },
    );
  }
}