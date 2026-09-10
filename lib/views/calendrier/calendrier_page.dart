import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/rendez_vous.dart';
import '../../viewmodels/calendrier_viewmodel.dart';
import '../rendez_vous/rendez_vous_edit_page.dart';

class CalendrierPage extends StatefulWidget {
  const CalendrierPage({super.key});

  @override
  State<CalendrierPage> createState() => _CalendrierPageState();
}

class _CalendrierPageState extends State<CalendrierPage> {
  late final CalendrierViewModel _viewModel;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  RendezVous? _selectedRendezVous;

  @override
  void initState() {
    super.initState();

    _viewModel = CalendrierViewModel();
    _viewModel.addListener(_onViewModelChanged);

    _selectedDay = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    _chargerDonnees();
  }

  void _onViewModelChanged() {
    if (!mounted) return;

    setState(() {});
  }

  Future<void> _chargerDonnees() async {
    await _viewModel.loadData();

    if (!mounted) return;

    if (_selectedRendezVous != null) {
      final id = _selectedRendezVous!.idRendezVous;

      try {
        _selectedRendezVous = _viewModel.rendezVous.firstWhere(
          (rdv) => rdv.idRendezVous == id,
        );
      } catch (_) {
        _selectedRendezVous = null;
      }

      setState(() {});
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();

    super.dispose();
  }

  // ============================================================
  // GESTION DES DATES
  // ============================================================

  DateTime? _convertirDate(String date) {
    try {
      return DateTime.parse(date);
    } catch (_) {}

    try {
      return DateFormat('dd/MM/yyyy').parse(date);
    } catch (_) {}

    return null;
  }

  bool _memeJour(
    RendezVous rdv,
    DateTime jour,
  ) {
    final date = _convertirDate(rdv.dateRDV);

    if (date == null) {
      return false;
    }

    return isSameDay(date, jour);
  }

  String _formaterDate(String date) {
    final dateConvertie = _convertirDate(date);

    if (dateConvertie == null) {
      return date;
    }

    return DateFormat('dd/MM/yyyy').format(dateConvertie);
  }

  List<RendezVous> get rendezVousDuJour {
    if (_selectedDay == null) {
      return [];
    }

    return _viewModel.rendezVous
        .where(
          (rdv) => _memeJour(
            rdv,
            _selectedDay!,
          ),
        )
        .toList();
  }

  // ============================================================
  // CONTACT
  // ============================================================

  String _afficherContact(RendezVous rdv) {
    return _viewModel.getContactName(rdv);
  }

  // ============================================================
  // STATUT
  // ============================================================

  String _afficherStatut(String statut) {
    switch (statut) {
      case 'Planifie':
        return 'Planifié';
      case 'Termine':
        return 'Terminé';
      case 'Annule':
        return 'Annulé';
      default:
        return statut;
    }
  }

  Color _couleurStatut(String statut) {
    switch (statut) {
      case 'Planifie':
        return Colors.blue;
      case 'Termine':
        return Colors.green;
      case 'Annule':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatutBadge(String statut) {
    final couleur = _couleurStatut(statut);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: couleur.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        _afficherStatut(statut),
        style: TextStyle(
          color: couleur,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // ============================================================
  // FAVORI
  // ============================================================

  Future<void> _changerFavori(RendezVous rdv) async {
    final nouveauFavori = !rdv.estFavori;

    final success = await _viewModel.modifierFavori(
      rdv.idRendezVous!,
      nouveauFavori,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _viewModel.errorMessage ??
                'Erreur lors de la modification du favori.',
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nouveauFavori
              ? 'Rendez-vous ajouté aux favoris.'
              : 'Rendez-vous retiré des favoris.',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // ============================================================
  // MODIFICATION DU STATUT
  // ============================================================

  Future<void> _afficherMenuStatut(RendezVous rdv) async {
    final statutSelectionne = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Modifier le statut',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(
                  Icons.schedule,
                  color: Colors.blue,
                ),
                title: const Text('Planifié'),
                trailing: rdv.statut == 'Planifie'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  Navigator.pop(
                    context,
                    'Planifie',
                  );
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                title: const Text('Terminé'),
                trailing: rdv.statut == 'Termine'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  Navigator.pop(
                    context,
                    'Termine',
                  );
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                title: const Text('Annulé'),
                trailing: rdv.statut == 'Annule'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  Navigator.pop(
                    context,
                    'Annule',
                  );
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (statutSelectionne == null ||
        statutSelectionne == rdv.statut) {
      return;
    }

    final success = await _viewModel.modifierStatut(
      rdv.idRendezVous!,
      statutSelectionne,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _viewModel.errorMessage ??
                'Erreur lors de la modification du statut.',
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Statut modifié : ${_afficherStatut(statutSelectionne)}.',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // ============================================================
  // CALENDRIER
  // ============================================================

  Widget _buildCalendrier() {
    return TableCalendar<RendezVous>(
      locale: 'fr_FR',

      firstDay: DateTime(2020),
      lastDay: DateTime(2100),

      focusedDay: _focusedDay,

      selectedDayPredicate: (day) {
        return isSameDay(
          _selectedDay,
          day,
        );
      },

      eventLoader: (day) {
        return _viewModel.rendezVous
            .where(
              (rdv) => _memeJour(
                rdv,
                day,
              ),
            )
            .toList();
      },

      onDaySelected: (
        selectedDay,
        focusedDay,
      ) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          _selectedRendezVous = null;
        });
      },

      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },

      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Color(0xFF159E9E),
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
      ),

      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),

      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        weekendStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // DÉTAILS DU RENDEZ-VOUS
  // ============================================================

  Widget _buildDetailsRendezVous() {
    if (_selectedRendezVous == null) {
      return const SizedBox.shrink();
    }

    final rdv = _selectedRendezVous!;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Détails du rendez-vous',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

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
              rdv.typeRDV,
            ),

            _detailRow(
              Icons.title,
              'Titre',
              rdv.titre,
            ),

            _detailRow(
              Icons.info_outline,
              'Statut',
              _afficherStatut(rdv.statut),
            ),

            _detailRow(
              rdv.estFavori
                  ? Icons.star
                  : Icons.star_border,
              'Favori',
              rdv.estFavori ? 'Oui' : 'Non',
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

  Widget _detailRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
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
            width: 100,
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
  // TABLE DES RENDEZ-VOUS
  // ============================================================

  Widget _buildRendezVousTable() {
    final rdvs = rendezVousDuJour;

    if (rdvs.isEmpty) {
      return const Center(
        child: Text(
          'Aucun rendez-vous pour cette date.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 24,

          headingRowColor:
              WidgetStateProperty.all(
            const Color(0xFF159E9E),
          ),

          headingTextStyle:
              const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),

          columns: const [
            DataColumn(
              label: Text('Date'),
            ),
            DataColumn(
              label: Text('Début'),
            ),
            DataColumn(
              label: Text('Fin'),
            ),
            DataColumn(
              label: Text('Type'),
            ),
            DataColumn(
              label: Text('Titre'),
            ),
            DataColumn(
              label: Text('Contact'),
            ),
            DataColumn(
              label: Text('Lieu'),
            ),
            DataColumn(
              label: Text('Description'),
            ),
            DataColumn(
              label: Text('Favori'),
            ),
            DataColumn(
              label: Text('Statut'),
            ),
          ],

          rows: rdvs.map((rdv) {
            final isSelected =
                _selectedRendezVous?.idRendezVous ==
                    rdv.idRendezVous;

            return DataRow(
              selected: isSelected,

              onSelectChanged: (_) {
                setState(() {
                  _selectedRendezVous = rdv;
                });
              },

              cells: [
                DataCell(
                  Text(
                    _formaterDate(
                      rdv.dateRDV,
                    ),
                  ),
                ),

                DataCell(
                  Text(rdv.heureDebut),
                ),

                DataCell(
                  Text(rdv.heureFin),
                ),

                DataCell(
                  Text(rdv.typeRDV),
                ),

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

                // FAVORI
                DataCell(
                  IconButton(
                    tooltip: rdv.estFavori
                        ? 'Retirer des favoris'
                        : 'Ajouter aux favoris',
                    icon: Icon(
                      rdv.estFavori
                          ? Icons.star
                          : Icons.star_border,
                      color: rdv.estFavori
                          ? Colors.amber
                          : Colors.grey,
                    ),
                    onPressed: () {
                      _changerFavori(rdv);
                    },
                  ),
                ),

                // STATUT
                DataCell(
                  InkWell(
                    onTap: () {
                      _afficherMenuStatut(rdv);
                    },
                    borderRadius:
                        BorderRadius.circular(20),
                    child: _buildStatutBadge(
                      rdv.statut,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // ============================================================
  // AJOUTER
  // ============================================================

  Future<void> _ajouterRendezVous() async {
    final resultat = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RendezVousEditPage(
          initialDate:
              _selectedDay ?? _focusedDay,
        ),
      ),
    );

    if (resultat == true) {
      await _chargerDonnees();
    }
  }

  // ============================================================
  // MODIFIER
  // ============================================================

  Future<void> _modifierRendezVous() async {
    if (_selectedRendezVous == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez sélectionner un rendez-vous.',
          ),
        ),
      );

      return;
    }

    final resultat = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RendezVousEditPage(
          rendezVous: _selectedRendezVous,
        ),
      ),
    );

    if (resultat == true) {
      await _chargerDonnees();
    }
  }

  // ============================================================
  // SUPPRIMER
  // ============================================================

  Future<void> _supprimerRendezVous() async {
    if (_selectedRendezVous == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez sélectionner un rendez-vous.',
          ),
        ),
      );

      return;
    }

    final rdv = _selectedRendezVous!;

    final confirmation =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Supprimer le rendez-vous',
          ),

          content: Text(
            'Voulez-vous vraiment supprimer le rendez-vous "${rdv.titre}" ?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text('Annuler'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
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

    final success =
        await _viewModel.supprimerRendezVous(
      rdv.idRendezVous!,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _viewModel.errorMessage ??
                'Erreur lors de la suppression.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _selectedRendezVous = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Rendez-vous supprimé avec succès.',
        ),
      ),
    );
  }

  // ============================================================
  // INTERFACE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final dateSelectionnee =
        _selectedDay ?? DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendrier',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor:
            const Color(0xFF159E9E),

        foregroundColor: Colors.white,

        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _chargerDonnees,
          ),
        ],
      ),

      body: _viewModel.isLoading
    ? const Center(
        child: CircularProgressIndicator(),
      )
    : SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // -----------------------------
              // CALENDRIER
              // -----------------------------

              Padding(
                padding: const EdgeInsets.all(8),
                child: _buildCalendrier(),
              ),

              // -----------------------------
              // DATE SÉLECTIONNÉE
              // -----------------------------

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: const Color(0xFFE8F7F7),
                child: Text(
                  'Rendez-vous du ${DateFormat('dd/MM/yyyy').format(dateSelectionnee)}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // -----------------------------
              // TABLE
              // -----------------------------

              _buildRendezVousTable(),

              // -----------------------------
              // DÉTAILS
              // -----------------------------

              _buildDetailsRendezVous(),

              // -----------------------------
              // BOUTONS
              // -----------------------------

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  12,
                  6,
                  12,
                  12,
                ),
                child: Padding(
  padding: const EdgeInsets.fromLTRB(
    12,
    6,
    12,
    12,
  ),
  child: Row(
    children: [
      Expanded(
        child: ElevatedButton.icon(
          onPressed: _ajouterRendezVous,
          icon: const Icon(Icons.add, size: 18),
          label: const Text(
            'Ajouter',
            style: TextStyle(fontSize: 13),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF159E9E),
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 42),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ),
      ),

      const SizedBox(width: 6),

      Expanded(
        child: ElevatedButton.icon(
          onPressed: _modifierRendezVous,
          icon: const Icon(Icons.edit, size: 18),
          label: const Text(
            'Modifier',
            style: TextStyle(fontSize: 13),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 42),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ),
      ),

      const SizedBox(width: 6),

      Expanded(
        child: ElevatedButton.icon(
          onPressed: _supprimerRendezVous,
          icon: const Icon(Icons.delete, size: 18),
          label: const Text(
            'Supprimer',
            style: TextStyle(fontSize: 13),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 42),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ),
      ),
    ],
  ),
),
              ),
            ],
          ),
        ),
      ),
    );
  }
}