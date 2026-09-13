
import 'package:flutter/material.dart';
import '../smart_assistant/smart_assistant_page.dart';
import '../../app_localizations.dart';
import '../../viewmodels/accueil_viewmodel.dart';
import '../professionnels/professionnels_page.dart';
import '../docteurs/docteurs_page.dart';
import '../calendrier/calendrier_page.dart';
import '../rendez_vous/rendez_vous_page.dart';
import '../rendez_vous/rendez_vous_edit_page.dart';
import '../parametres/parametres_page.dart';
import '../../app_settings.dart';

class AccueilPage extends StatefulWidget {
  final AppSettings appSettings;

  const AccueilPage({super.key, required this.appSettings});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  late final AccueilViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AccueilViewModel();
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: widget.appSettings.themeColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 25),

              // Logo
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.calendar_month,
                  size: 65,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 15),

              // Application name
              const Text(
                'Smart Agenda',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // Today's date
              Text(
                _translateToday(t),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                _viewModel.dateAujourdhui,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // Menu
              _menuButton(
                context,
                icon: Icons.calendar_month,
                text: t.calendar,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CalendrierPage(appSettings: widget.appSettings),
                    ),
                  );
                },
              ),

              _menuButton(
                context,
                icon: Icons.event_note,
                text: _translateTodayAppointments(t),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RendezVousPage(
                        appSettings: widget.appSettings,
                      ),
                    ),
                  );
                },
              ),

              _menuButton(
                context,
                icon: Icons.add_circle_outline,
                text: _translateAddAppointment(t),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RendezVousEditPage(
                        appSettings: widget.appSettings,
                      ),
                    ),
                  );
                },
              ),
              _menuButton(
  context,
  icon: Icons.smart_toy_outlined,
  text: 'Smart Assistant',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SmartAssistantPage(),
      ),
    );
  },
),

              _menuButton(
                context,
                icon: Icons.business_center,
                text: t.professional ,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfessionnelsPage(
                        appSettings: widget.appSettings,
                      ),
                    ),
                  );
                },
              ),

              _menuButton(
                context,
                icon: Icons.medical_services_outlined,
                text: t.doctor ,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DocteursPage(
                        appSettings: widget.appSettings,
                      ),
                    ),
                  );
                },
              ),

              _menuButton(
                context,
                icon: Icons.settings_outlined,
                text: t.settings,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ParametresPage(appSettings: widget.appSettings),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _translateToday(AppLocalizations t) {
    if (t.isEnglish) {
      return 'Today:';
    }

    if (t.isArabic) {
      return 'اليوم:';
    }

    return "Aujourd'hui :";
  }

  String _translateTodayAppointments(AppLocalizations t) {
    if (t.isEnglish) {
      return "Today's appointments";
    }

    if (t.isArabic) {
      return 'مواعيد اليوم';
    }

    return 'Rendez-vous du jour';
  }

  String _translateAddAppointment(AppLocalizations t) {
    if (t.isEnglish) {
      return 'Add appointment';
    }

    if (t.isArabic) {
      return 'إضافة موعد';
    }

    return 'Ajouter RDV';
  }

  Widget _menuButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      child: SizedBox(
        width: double.infinity,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 35),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

