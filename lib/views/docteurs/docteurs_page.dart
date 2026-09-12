import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../app_localizations.dart';
import '../../models/docteur.dart';
import '../../viewmodels/docteur_viewmodel.dart';
import 'docteur_edit_page.dart';

class DocteursPage extends StatefulWidget {
  final AppSettings appSettings;

  const DocteursPage({
    super.key,
    required this.appSettings,
  });

  @override
  State<DocteursPage> createState() => _DocteursPageState();
}

class _DocteursPageState extends State<DocteursPage> {
  late final DocteurViewModel _viewModel;

  int? selectedIndex;

  @override
  void initState() {
    super.initState();

    _viewModel = DocteurViewModel();
    _viewModel.addListener(_onViewModelChanged);

    _chargerDocteurs();
  }

  void _onViewModelChanged() {
    if (!mounted) return;

    setState(() {});
  }

  Future<void> _chargerDocteurs() async {
    await _viewModel.loadDocteurs();
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

    final docteurs = _viewModel.docteurs;
    final isLoading = _viewModel.isLoading;

    return Scaffold(
      backgroundColor: widget.appSettings.themeColor,

      appBar: AppBar(
        backgroundColor: widget.appSettings.themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          t.doctors,
          style: const TextStyle(fontSize: 28),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : docteurs.isEmpty
                    ? Center(
                        child: Text(
                          t.noDoctors,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        itemCount: docteurs.length,
                        itemBuilder: (context, index) {
                          final docteur = docteurs[index];

                          final isSelected =
                              selectedIndex == index;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            child: Card(
                              color: isSelected
                                  ? widget.appSettings.themeColor
                                      .withOpacity(0.8)
                                  : Colors.white.withOpacity(0.12),

                              child: Padding(
                                padding: const EdgeInsets.all(12),

                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,

                                  children: [
                                    // NOM
                                    Text(
                                      docteur.nom,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // SPÉCIALITÉ
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.medical_services,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),

                                        Expanded(
                                          child: Text(
                                            docteur.specialite
                                                        ?.isNotEmpty ==
                                                    true
                                                ? docteur.specialite!
                                                : t.notProvided,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 6),

                                    // TÉLÉPHONE
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.phone,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),

                                        Expanded(
                                          child: Text(
                                            docteur.telephone
                                                        ?.isNotEmpty ==
                                                    true
                                                ? docteur.telephone!
                                                : t.notProvided,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 6),

                                    // ADRESSE
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),

                                        Expanded(
                                          child: Text(
                                            docteur.adresseCabinet
                                                        ?.isNotEmpty ==
                                                    true
                                                ? docteur.adresseCabinet!
                                                : t.notProvided,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),

          Padding(
            padding: const EdgeInsets.only(
              left: 40,
              right: 40,
              bottom: 25,
            ),
            child: Column(
              children: [
                // NOUVEAU
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _nouveauDocteur,

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          widget.appSettings.themeColor,
                      foregroundColor: Colors.white,
                    ),

                    icon: const Icon(Icons.add),

                    label: Text(
                      t.add,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // MODIFIER
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: selectedIndex == null
                        ? null
                        : _modifierDocteur,

                    icon: const Icon(Icons.edit),

                    label: Text(
                      t.edit,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // SUPPRIMER
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),

                    onPressed: selectedIndex == null
                        ? null
                        : _supprimerDocteur,

                    icon: const Icon(Icons.delete),

                    label: Text(
                      t.delete,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================
  // NOUVEAU DOCTEUR
  // ============================

  Future<void> _nouveauDocteur() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocteurEditPage(
          appSettings: widget.appSettings,
        ),
      ),
    );

    if (!mounted) return;

    setState(() {
      selectedIndex = null;
    });

    await _chargerDocteurs();
  }

  // ============================
  // MODIFIER DOCTEUR
  // ============================

  Future<void> _modifierDocteur() async {
    if (selectedIndex == null) return;

    final docteurs = _viewModel.docteurs;
    final docteurActuel = docteurs[selectedIndex!];

    final docteurMap = <String, String>{
      'idDocteur':
          docteurActuel.idDocteur?.toString() ?? '',
      'nom': docteurActuel.nom,
      'specialite':
          docteurActuel.specialite ?? '',
      'adresseCabinet':
          docteurActuel.adresseCabinet ?? '',
      'telephone':
          docteurActuel.telephone ?? '',
    };

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocteurEditPage(
          docteur: docteurMap,
          appSettings: widget.appSettings,
        ),
      ),
    );

    if (!mounted) return;

    setState(() {
      selectedIndex = null;
    });

    await _chargerDocteurs();
  }

  // ============================
  // SUPPRIMER DOCTEUR
  // ============================

  Future<void> _supprimerDocteur() async {
    if (selectedIndex == null) return;

    final t = AppLocalizations.of(context);

    final docteurs = _viewModel.docteurs;
    final docteur = docteurs[selectedIndex!];

    final confirmation = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: Text(t.delete),

          content: Text(
            '${t.confirmDeleteDoctor}\n\n'
            '${docteur.nom}',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },

              child: Text(t.cancel),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },

              child: Text(
                t.delete,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmation != true) return;

    final success =
        await _viewModel.supprimerDocteur(
      docteur.idDocteur!,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _viewModel.errorMessage ??
                t.errorDeletingDoctor,
          ),
        ),
      );

      return;
    }

    setState(() {
      selectedIndex = null;
    });
  }
}