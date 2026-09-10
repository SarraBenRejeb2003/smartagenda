import 'package:flutter/material.dart';

import '../../models/professionnel.dart';
import '../../viewmodels/professionnel_viewmodel.dart';
import 'professionnel_edit_page.dart';

class ProfessionnelsPage extends StatefulWidget {
  const ProfessionnelsPage({super.key});

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
    final professionnels = _viewModel.professionnels;
    final isLoading = _viewModel.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF159E9E),

      appBar: AppBar(
        backgroundColor: const Color(0xFF159E9E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Professionnels',
          style: TextStyle(fontSize: 28),
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
                    ? const Center(
                        child: Text(
                          'Aucun professionnel',
                          style: TextStyle(
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
                          final professionnel = professionnels[index];

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
                                  ? Colors.blue
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
                                                : 'Non renseignée',
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
                                                : 'Non renseignée',
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
                                                : 'Non renseigné',
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
                                                : 'Non renseigné',
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

                    icon: const Icon(Icons.add),

                    label: const Text(
                      'Nouveau',
                      style: TextStyle(fontSize: 20),
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

                    label: const Text(
                      'Modifier',
                      style: TextStyle(fontSize: 20),
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

                    label: const Text(
                      'Supprimer',
                      style: TextStyle(fontSize: 20),
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
      builder: (context) => const ProfessionnelEditPage(),
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
  final professionnelActuel = professionnels[selectedIndex!];

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

    final professionnels = _viewModel.professionnels;

    final professionnel =
        professionnels[selectedIndex!];

    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer'),

          content: Text(
            'Voulez-vous vraiment supprimer '
            '${professionnel.nom} ?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Annuler'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Supprimer',
                style: TextStyle(
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
            _viewModel.errorMessage ??
                'Erreur lors de la suppression du professionnel.',
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