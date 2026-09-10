import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/rendez_vous.dart';
import '../../models/professionnel.dart';
import '../../models/docteur.dart';
import '../../viewmodels/rendez_vous_viewmodel.dart';
import 'rendez_vous_edit_page.dart';

class RendezVousPage extends StatefulWidget {
  const RendezVousPage({super.key});

  @override
  State<RendezVousPage> createState() => _RendezVousPageState();
}

class _RendezVousPageState extends State<RendezVousPage> {
  late final RendezVousViewModel _viewModel;

  int? selectedIndex;

  @override
  void initState() {
    super.initState();

    _viewModel = RendezVousViewModel();
    _viewModel.addListener(_onViewModelChanged);

    _chargerDonnees();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();

    super.dispose();
  }

  void _onViewModelChanged() {
    if (!mounted) return;

    setState(() {});
  }

  // ============================================================
  // CHARGER LES DONNÉES
  // ============================================================

  Future<void> _chargerDonnees() async {
    await _viewModel.loadData();

    if (!mounted) return;

    setState(() {
      selectedIndex = null;
    });

    if (_viewModel.errorMessage != null) {
      _afficherMessage(_viewModel.errorMessage!);
      _viewModel.clearError();
    }
  }

  // ============================================================
  // NOUVEAU RENDEZ-VOUS
  // ============================================================

  Future<void> _nouveauRendezVous() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RendezVousEditPage(),
      ),
    );

    if (result == true) {
      await _chargerDonnees();
    }
  }

  // ============================================================
  // MODIFIER
  // ============================================================

  Future<void> _modifierRendezVous() async {
    if (selectedIndex == null) {
      _afficherMessage(
        'Veuillez sélectionner un rendez-vous.',
      );
      return;
    }

    final rendezVous = _viewModel.rendezVous;

    if (selectedIndex! >= rendezVous.length) {
      return;
    }

    final RendezVous rdv = rendezVous[selectedIndex!];

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RendezVousEditPage(
          rendezVous: rdv,
        ),
      ),
    );

    if (result == true) {
      await _chargerDonnees();
    }
  }

  // ============================================================
  // SUPPRIMER
  // ============================================================

  Future<void> _supprimerRendezVous() async {
    if (selectedIndex == null) {
      _afficherMessage(
        'Veuillez sélectionner un rendez-vous.',
      );
      return;
    }

    final rendezVous = _viewModel.rendezVous;

    if (selectedIndex! >= rendezVous.length) {
      return;
    }

    final RendezVous rdv = rendezVous[selectedIndex!];

    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Text(
            'Voulez-vous vraiment supprimer le rendez-vous '
            '"${rdv.titre}" ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmation != true) {
      return;
    }

    final success = await _viewModel.supprimerRendezVous(
      rdv.idRendezVous!,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        selectedIndex = null;
      });

      _afficherMessage(
        'Rendez-vous supprimé avec succès.',
      );
    } else if (_viewModel.errorMessage != null) {
      _afficherMessage(
        _viewModel.errorMessage!,
      );

      _viewModel.clearError();
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _afficherMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formaterDate(String date) {
    // Nouveau format : yyyy-MM-dd
    try {
      final parsedDate = DateTime.parse(date);

      return DateFormat(
        'dd/MM/yyyy',
      ).format(parsedDate);
    } catch (_) {}

    // Ancien format éventuel : dd/MM/yyyy
    try {
      final parsedDate =
          DateFormat('dd/MM/yyyy').parse(date);

      return DateFormat(
        'dd/MM/yyyy',
      ).format(parsedDate);
    } catch (_) {}

    return date;
  }

  // ============================================================
  // TYPE
  // ============================================================

  String _afficherType(String type) {
    switch (type) {
      case 'Professionnel':
        return 'Professionnel';

      case 'Medical':
        return 'Médical';

      case 'Prive':
        return 'Privé';

      default:
        return type;
    }
  }

  // ============================================================
  // AFFICHER LE CONTACT
  // ============================================================

  String _afficherContact(RendezVous rdv) {
    if (rdv.typeRDV == 'Professionnel') {
      final Professionnel? professionnel =
          _viewModel.getProfessionnel(
        rdv.idProfessionnel,
      );

      if (professionnel == null) {
        return '';
      }

      final details = <String>[];

      if (professionnel.societe != null &&
          professionnel.societe!.trim().isNotEmpty) {
        details.add(
          professionnel.societe!.trim(),
        );
      }

      if (professionnel.fonction != null &&
          professionnel.fonction!.trim().isNotEmpty) {
        details.add(
          professionnel.fonction!.trim(),
        );
      }

      if (details.isEmpty) {
        return professionnel.nom;
      }

      return '${professionnel.nom} - '
          '${details.join(' - ')}';
    }

    if (rdv.typeRDV == 'Medical') {
      final Docteur? docteur =
          _viewModel.getDocteur(
        rdv.idDocteur,
      );

      if (docteur == null) {
        return '';
      }

      if (docteur.specialite != null &&
          docteur.specialite!.trim().isNotEmpty) {
        return '${docteur.nom} - '
            '${docteur.specialite!.trim()}';
      }

      return docteur.nom;
    }

    return 'Privé';
  }

  // ============================================================
  // DÉTAILS DU RENDEZ-VOUS
  // ============================================================

  Widget _buildDetailsRendezVous() {
    if (selectedIndex == null) {
      return const SizedBox.shrink();
    }

    final rendezVous = _viewModel.rendezVous;

    if (selectedIndex! >= rendezVous.length) {
      return const SizedBox.shrink();
    }

    final rdv = rendezVous[selectedIndex!];

    return Card(
      margin: const EdgeInsets.fromLTRB(
        16,
        4,
        16,
        12,
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.event_note,
                  color: Color(0xFF159E9E),
                ),
                SizedBox(width: 8),
                Text(
                  'Détails du rendez-vous',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _detailRow(
              Icons.calendar_today,
              'Date',
              _formaterDate(rdv.dateRDV),
            ),
            _detailRow(
              Icons.access_time,
              'Horaire',
              '${rdv.heureDebut} - ${rdv.heureFin}',
            ),
            _detailRow(
              Icons.category,
              'Type',
              _afficherType(rdv.typeRDV),
            ),
            _detailRow(
              Icons.title,
              'Titre',
              rdv.titre,
            ),
            if (_afficherContact(rdv).isNotEmpty)
              _detailRow(
                Icons.person,
                rdv.typeRDV == 'Medical'
                    ? 'Docteur'
                    : rdv.typeRDV == 'Professionnel'
                        ? 'Professionnel'
                        : 'Contact',
                _afficherContact(rdv),
              ),
            if (rdv.lieu != null &&
                rdv.lieu!.trim().isNotEmpty)
              _detailRow(
                Icons.location_on,
                'Lieu',
                rdv.lieu!,
              ),
            if (rdv.description != null &&
                rdv.description!.trim().isNotEmpty)
              _detailRow(
                Icons.description,
                'Description',
                rdv.description!,
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LIGNE DE DÉTAIL
  // ============================================================

  Widget _detailRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 9,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF159E9E),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 105,
            child: Text(
              '$label :',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLEAU
  // ============================================================

  Widget _buildTableau() {
    final rendezVous = _viewModel.rendezVous;

    if (rendezVous.isEmpty) {
      return const Center(
        child: Text(
          'Aucun rendez-vous enregistré.',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
      );
    }

    const turquoise = Color(0xFF159E9E);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 30,
          headingRowColor:
              WidgetStateProperty.all(
            turquoise.withOpacity(0.15),
          ),
          columns: const [
            DataColumn(
              label: Text(
                'Date',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Début',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Fin',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Type',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Titre',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Contact',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Lieu',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          rows: List.generate(
            rendezVous.length,
            (index) {
              final rdv = rendezVous[index];

              final isSelected =
                  selectedIndex == index;

              return DataRow(
                selected: isSelected,
                onSelectChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      selectedIndex = index;
                    } else {
                      selectedIndex = null;
                    }
                  });
                },
                cells: [
                  // DATE
                  DataCell(
                    Text(
                      _formaterDate(
                        rdv.dateRDV,
                      ),
                    ),
                  ),

                  // DÉBUT
                  DataCell(
                    Text(
                      rdv.heureDebut,
                    ),
                  ),

                  // FIN
                  DataCell(
                    Text(
                      rdv.heureFin,
                    ),
                  ),

                  // TYPE
                  DataCell(
                    Text(
                      _afficherType(
                        rdv.typeRDV,
                      ),
                    ),
                  ),

                  // TITRE
                  DataCell(
                    SizedBox(
                      width: 160,
                      child: Text(
                        rdv.titre,
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  // CONTACT
                  DataCell(
                    SizedBox(
                      width: 230,
                      child: Text(
                        _afficherContact(rdv),
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  // LIEU
                  DataCell(
                    SizedBox(
                      width: 150,
                      child: Text(
                        rdv.lieu ?? '',
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  // DESCRIPTION
                  DataCell(
                    SizedBox(
                      width: 250,
                      child: Text(
                        rdv.description ?? '',
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INTERFACE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    const turquoise = Color(0xFF159E9E);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rendez-Vous',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: turquoise,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
            ),
            onPressed: _chargerDonnees,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        color: Colors.white,
        child: _viewModel.isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  // ==================================================
                  // TABLEAU
                  // ==================================================

                  Expanded(
                    child: _buildTableau(),
                  ),

                  // ==================================================
                  // DÉTAILS
                  // ==================================================

                  _buildDetailsRendezVous(),

                  // ==================================================
                  // BOUTONS
                  // ==================================================

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment:
                          WrapAlignment.center,
                      children: [
                        // ------------------------------
                        // NOUVEAU
                        // ------------------------------

                        ElevatedButton.icon(
                          onPressed:
                              _nouveauRendezVous,
                          icon: const Icon(
                            Icons.add,
                          ),
                          label: const Text(
                            'Nouveau',
                          ),
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                turquoise,
                            foregroundColor:
                                Colors.white,
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                        ),

                        // ------------------------------
                        // MODIFIER
                        // ------------------------------

                        ElevatedButton.icon(
                          onPressed:
                              _modifierRendezVous,
                          icon: const Icon(
                            Icons.edit,
                          ),
                          label: const Text(
                            'Modifier',
                          ),
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.orange,
                            foregroundColor:
                                Colors.white,
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                        ),

                        // ------------------------------
                        // SUPPRIMER
                        // ------------------------------

                        ElevatedButton.icon(
                          onPressed:
                              _supprimerRendezVous,
                          icon: const Icon(
                            Icons.delete,
                          ),
                          label: const Text(
                            'Supprimer',
                          ),
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.red,
                            foregroundColor:
                                Colors.white,
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}