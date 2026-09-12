
import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../models/parametres.dart';
import '../../viewmodels/parametres_viewmodel.dart';
import '../../app_localizations.dart';

class ParametresPage extends StatefulWidget {
  final AppSettings appSettings;

  const ParametresPage({
    super.key,
    required this.appSettings,
  });

  @override
  State<ParametresPage> createState() => _ParametresPageState();
}

class _ParametresPageState extends State<ParametresPage> {
  late final ParametresViewModel _viewModel;

  int _delaiNotification = 30;
  String _themeCouleur = '#6750A4';
  String _formatHeure = '24h';
  String _langue = 'fr';

  @override
  void initState() {
    super.initState();

    _viewModel = ParametresViewModel();
    _chargerParametres();
  }

  Future<void> _chargerParametres() async {
    await _viewModel.loadParametres();

    if (!mounted) return;

    final parametres = _viewModel.parametres;

    if (parametres != null) {
      setState(() {
        _delaiNotification = parametres.delaiNotifDefaut;
        _themeCouleur = parametres.themeCouleur;
        _formatHeure = parametres.formatHeure;
        _langue = parametres.langue;
      });
    }
  }

  Future<void> _sauvegarderParametres() async {
    final anciensParametres = _viewModel.parametres;

    final nouveauxParametres = Parametres(
      idParametres: anciensParametres?.idParametres,
      delaiNotifDefaut: _delaiNotification,
      themeCouleur: _themeCouleur,
      formatHeure: _formatHeure,
      langue: _langue,
    );

    final succes =
        await _viewModel.modifierParametres(nouveauxParametres);

    if (succes) {
      await widget.appSettings.update(nouveauxParametres);
    }

    if (!mounted) return;

    final t = AppLocalizations.of(context);

    if (succes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.settingsSaved),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _viewModel.errorMessage ?? t.errorSavingSettings,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings),
      ),
      body: _viewModel.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionTitle(
                  t.notifications,
                  Icons.notifications_outlined,
                ),

                const SizedBox(height: 8),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DropdownButtonFormField<int>(
                      initialValue: _delaiNotification,
                      decoration: InputDecoration(
                        labelText: t.reminderDelay,
                        prefixIcon: const Icon(
                          Icons.alarm_outlined,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 5,
                          child: Text(t.minutesBefore5),
                        ),
                        DropdownMenuItem(
                          value: 10,
                          child: Text(t.minutesBefore10),
                        ),
                        DropdownMenuItem(
                          value: 15,
                          child: Text(t.minutesBefore15),
                        ),
                        DropdownMenuItem(
                          value: 30,
                          child: Text(t.minutesBefore30),
                        ),
                        DropdownMenuItem(
                          value: 60,
                          child: Text(t.hourBefore1),
                        ),
                        DropdownMenuItem(
                          value: 120,
                          child: Text(t.hoursBefore2),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _delaiNotification = value;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                _buildSectionTitle(
                  t.appearance,
                  Icons.palette_outlined,
                ),

                const SizedBox(height: 8),

                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          _couleurDepuisHex(_themeCouleur),
                      child: const Icon(
                        Icons.palette,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(t.themeColor),
                    subtitle: Text(_themeCouleur),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onTap: _choisirCouleur,
                  ),
                ),

                const SizedBox(height: 12),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DropdownButtonFormField<String>(
                      initialValue: _formatHeure,
                      decoration: InputDecoration(
                        labelText: t.timeFormat,
                        prefixIcon: const Icon(
                          Icons.schedule_outlined,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: '24h',
                          child: Text(t.twentyFourHours),
                        ),
                        DropdownMenuItem(
                          value: '12h',
                          child: Text(t.twelveHours),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _formatHeure = value;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                _buildSectionTitle(
                  t.language,
                  Icons.language_outlined,
                ),

                const SizedBox(height: 8),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DropdownButtonFormField<String>(
                      initialValue: _langue,
                      decoration: InputDecoration(
                        labelText: t.appLanguage,
                        prefixIcon: const Icon(
                          Icons.translate,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'fr',
                          child: Text(t.french),
                        ),
                        DropdownMenuItem(
                          value: 'en',
                          child: Text(t.english),
                        ),
                        DropdownMenuItem(
                          value: 'ar',
                          child: Text(t.arabic),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _langue = value;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _sauvegarderParametres,
                    icon: const Icon(
                      Icons.save_outlined,
                    ),
                    label: Text(t.saveSettings),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleLarge,
        ),
      ],
    );
  }

  Future<void> _choisirCouleur() async {
    final t = AppLocalizations.of(context);

    const couleurs = [
      '#6750A4',
      '#3F51B5',
      '#2196F3',
      '#009688',
      '#4CAF50',
      '#FF9800',
      '#F44336',
      '#9C27B0',
    ];

    final couleur = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.themeColorDialog),
          content: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: couleurs.map((hex) {
              final couleur =
                  _couleurDepuisHex(hex);

              return InkWell(
                onTap: () {
                  Navigator.pop(context, hex);
                },
                borderRadius:
                    BorderRadius.circular(30),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: couleur,
                  child: hex == _themeCouleur
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        );
      },
    );

    if (couleur == null) return;

    setState(() {
      _themeCouleur = couleur;
    });
  }

  Color _couleurDepuisHex(String hex) {
    final valeur = hex.replaceFirst('#', '');

    return Color(
      int.parse(
        'FF$valeur',
        radix: 16,
      ),
    );
  }
}
