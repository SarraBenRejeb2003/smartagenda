
import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../app_localizations.dart';
import '../../models/professionnel.dart';
import '../../viewmodels/professionnel_viewmodel.dart';
import 'professionnel_edit_page.dart';

class ProfessionnelsPage extends StatefulWidget {
  final AppSettings appSettings;

  const ProfessionnelsPage({
    super.key,
    required this.appSettings,
  });

  @override
  State<ProfessionnelsPage> createState() => _ProfessionnelsPageState();
}

class _ProfessionnelsPageState extends State<ProfessionnelsPage> {
  late final ProfessionnelViewModel _viewModel;

  int? selectedIndex;

  @override
  void initState() {
    super.initState();

    _viewModel = ProfessionnelViewModel();
    _viewModel.addListener(_onViewModelChanged);

    _chargerProfessionnels();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _chargerProfessionnels() async {
    await _viewModel.loadProfessionnels();
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

    final professionnels = _viewModel.professionnels;
    final isLoading = _viewModel.isLoading;

    return Scaffold(
      backgroundColor: widget.appSettings.themeColor,

      appBar: AppBar(
        backgroundColor: widget.appSettings.themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          t.professionals,
          style: const TextStyle(fontSize: 28),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          // =========================
          // LISTE DES PROFESSIONNELS
          // =========================
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : professionnels.isEmpty
                    ? Center(
                        child: Text(
                          t.noProfessionals,
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
                        itemCount: professionnels.length,
                        itemBuilder: (context, index) {
                          final professionnel =
                              professionnels[index];

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
                                      professionnel.nom,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // SOCIÉTÉ
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.business,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            professionnel.societe
                                                        ?.isNotEmpty ==
                                                    true
                                                ? professionnel.societe!
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

                                    // FONCTION / PROFESSION
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.work,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            professionnel.fonction
                                                        ?.isNotEmpty ==
                                                    true
                                                ? professionnel.fonction!
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
                                            professionnel.telephone
                                                        ?.isNotEmpty ==
                                                    true
                                                ? professionnel.telephone!
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

                                    // EMAIL
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.email,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            professionnel.email
                                                        ?.isNotEmpty ==
                                                    true
                                                ? professionnel.email!
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

          // =========================
          // BOUTONS
          // =========================
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
                    onPressed: _nouveauProfessionnel,
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
                        : _modifierProfessionnel,
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
                        : _supprimerProfessionnel,
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

  // ==========================================
  // NOUVEAU PROFESSIONNEL
  // ==========================================
  Future<void> _nouveauProfessionnel() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfessionnelEditPage(
          appSettings: widget.appSettings,
        ),
      ),
    );

    if (!mounted) return;

    setState(() {
      selectedIndex = null;
    });

    await _chargerProfessionnels();
  }

  // ==========================================
  // MODIFIER PROFESSIONNEL
  // ==========================================
  Future<void> _modifierProfessionnel() async {
    if (selectedIndex == null) return;

    final professionnels = _viewModel.professionnels;
    final professionnelActuel =
        professionnels[selectedIndex!];

    final professionnelMap = <String, String>{
      'idProfessionnel':
          professionnelActuel.idProfessionnel?.toString() ?? '',
      'nom': professionnelActuel.nom,
      'societe': professionnelActuel.societe,
      'profession': professionnelActuel.fonction,
      'telephone': professionnelActuel.telephone,
      'email': professionnelActuel.email,
    };

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfessionnelEditPage(
          professionnel: professionnelMap,
          appSettings: widget.appSettings,
        ),
      ),
    );

    if (!mounted) return;

    setState(() {
      selectedIndex = null;
    });

    await _chargerProfessionnels();
  }

  // ==========================================
  // SUPPRIMER PROFESSIONNEL
  // ==========================================
  Future<void> _supprimerProfessionnel() async {
    if (selectedIndex == null) return;

    final t = AppLocalizations.of(context);

    final professionnels = _viewModel.professionnels;

    final professionnel =
        professionnels[selectedIndex!];

    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.deleteProfessional),

          content: Text(
            t.confirmDeleteProfessional,
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

    // Supprimer via le ViewModel
    final success =
        await _viewModel.supprimerProfessionnel(
      professionnel.idProfessionnel!,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.errorDeletingProfessional,
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

