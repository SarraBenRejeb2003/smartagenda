import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../professionnels/professionnels_page.dart';
import '../docteurs/docteurs_page.dart';
import '../calendrier/calendrier_page.dart';
import '../rendez_vous/rendez_vous_page.dart';
import '../rendez_vous/rendez_vous_edit_page.dart';

class AccueilPage extends StatelessWidget {
  const AccueilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final date = DateFormat('dd/MM/yyyy').format(today);

    return Scaffold(
      backgroundColor: const Color(0xFF159E9E),
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
              const Text(
                "Aujourd'hui :",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                date,
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
                text: 'Calendrier',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CalendrierPage(),
                    ),
                  );
                },
              ),

              _menuButton(
                context,
                icon: Icons.event_note,
                text: 'Rendez-vous du jour',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RendezVousPage(),
                    ),
                  );
                },
              ),

              _menuButton(
                context,
                icon: Icons.add_circle_outline,
                text: 'Ajouter RDV',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RendezVousEditPage(),
                    ),
                  );
                },
              ),

              _menuButton(
                context,
                icon: Icons.business_center,
                text: 'Professionnels',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfessionnelsPage(),
                    ),
                  );
                },
              ),

              _menuButton(
                context,
                icon: Icons.medical_services_outlined,
                text: 'Docteurs',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DocteursPage(),
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
                    style: const TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String page) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$page sera disponible prochainement.')),
    );
  }
}
