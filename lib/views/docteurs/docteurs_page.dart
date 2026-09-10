import 'package:flutter/material.dart';

import '../../models/docteur.dart';
import '../../viewmodels/docteur_viewmodel.dart';
import 'docteur_edit_page.dart';

class DocteursPage extends StatefulWidget {
  const DocteursPage({super.key});

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
    final docteurs = _viewModel.docteurs;
    final isLoading = _viewModel.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF159E9E),

      appBar: AppBar(
        backgroundColor: const Color(0xFF159E9E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Docteurs',
          style: TextStyle(fontSize: 28),
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
                    ? const Center(
                        child: Text(
                          'Aucun docteur',
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
                                            docteur.telephone
                                                        ?.isNotEmpty ==
                                                    true
                                                ? docteur.telephone!
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
                                                : 'Non renseignée',
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _nouveauDocteur,
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Nouveau',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: selectedIndex == null
                        ? null
                        : _modifierDocteur,
                    icon: const Icon(Icons.edit),
                    label: const Text(
                      'Modifier',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

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

  // ============================
  // NOUVEAU DOCTEUR
  // ============================
 Future<void> _nouveauDocteur() async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const DocteurEditPage(),
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
    'specialite': docteurActuel.specialite ?? '',
    'adresseCabinet':
        docteurActuel.adresseCabinet ?? '',
    'telephone': docteurActuel.telephone ?? '',
  };

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DocteurEditPage(
        docteur: docteurMap,
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

    final docteurs = _viewModel.docteurs;
    final docteur = docteurs[selectedIndex!];

    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer'),
          content: Text(
            'Voulez-vous vraiment supprimer '
            '${docteur.nom} ?',
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
                style: TextStyle(color: Colors.red),
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
                'Erreur lors de la suppression du docteur.',
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