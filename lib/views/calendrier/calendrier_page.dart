
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../app_localizations.dart';
import '../../app_settings.dart';
import '../../models/rendez_vous.dart';
import '../../viewmodels/calendrier_viewmodel.dart';
import '../rendez_vous/rendez_vous_edit_page.dart';

class CalendrierPage extends StatefulWidget {
  final AppSettings appSettings;

  const CalendrierPage({
    super.key,
    required this.appSettings,
  });

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
  // DATES
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

  bool _memeJour(RendezVous rdv, DateTime jour) {
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

  String _formaterHeure(String heure) {
    try {
      final parsedTime = DateFormat('HH:mm').parse(heure);

      if (widget.appSettings.parametres.formatHeure == '12h') {
        return DateFormat('h:mm a').format(parsedTime);
      }

      return DateFormat('HH:mm').format(parsedTime);
    } catch (_) {
      return heure;
    }
  }

  List<RendezVous> get rendezVousDuJour {
    if (_selectedDay == null) {
      return [];
    }

    return _viewModel.rendezVous
        .where((rdv) => _memeJour(rdv, _selectedDay!))
        .toList();
  }

  // ============================================================
  // CONTACT
  // ============================================================

  String _afficherContact(RendezVous rdv) {
  final t = AppLocalizations.of(context);

  if (rdv.typeRDV == 'Professionnel') {
    return _viewModel.getContactName(rdv);
  }

  if (rdv.typeRDV == 'Medical') {
    return _viewModel.getContactName(rdv);
  }

  if (rdv.typeRDV == 'Private' ||
      rdv.typeRDV == 'Prive' ||
      rdv.typeRDV == 'Privé') {
    return t.privateAppointment;
  }

  return _viewModel.getContactName(rdv);
}
// ============================================================
// TYPE DE RENDEZ-VOUS
// ============================================================

String _afficherType(String type, AppLocalizations t) {
  switch (type) {
    case 'Professionnel':
      return t.professional;

    case 'Medical':
      return t.medical;

    case 'Private':
    case 'Prive':
    case 'Privé':
      return t.privateAppointment;

    default:
      return type;
  }
}
  // ============================================================
  // STATUT
  // ============================================================

  String _afficherStatut(String statut, AppLocalizations t) {
    switch (statut) {
      case 'Planifie':
        return t.scheduled;
      case 'Termine':
        return t.completed;
      case 'Annule':
        return t.cancelled;
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

  Widget _buildStatutBadge(
    String statut,
    AppLocalizations t,
  ) {
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
        _afficherStatut(statut, t),
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

  Future<void> _changerFavori(
    RendezVous rdv,
    AppLocalizations t,
  ) async {
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
              ? t.favoriteAdded
              : t.favoriteRemoved,
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // ============================================================
  // MODIFICATION DU STATUT
  // ============================================================

  Future<void> _afficherMenuStatut(
    RendezVous rdv,
    AppLocalizations t,
  ) async {
    final statutSelectionne = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  t.modifyStatus,
                  style: const TextStyle(
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
                title: Text(t.scheduled),
                trailing: rdv.statut == 'Planifie'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  Navigator.pop(context, 'Planifie');
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                title: Text(t.completed),
                trailing: rdv.statut == 'Termine'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  Navigator.pop(context, 'Termine');
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                title: Text(t.cancelled),
                trailing: rdv.statut == 'Annule'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  Navigator.pop(context, 'Annule');
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
          '${t.statusModified} : '
          '${_afficherStatut(statutSelectionne, t)}.',
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
      locale: Localizations.localeOf(context).toString(),

      firstDay: DateTime(2020),
      lastDay: DateTime(2100),

      focusedDay: _focusedDay,

      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },

      eventLoader: (day) {
        return _viewModel.rendezVous
            .where((rdv) => _memeJour(rdv, day))
            .toList();
      },

      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          _selectedRendezVous = null;
        });
      },

      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },

      calendarStyle: CalendarStyle(
        todayDecoration: const BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: widget.appSettings.themeColor,
          shape: BoxShape.circle,
        ),
        markerDecoration: const BoxDecoration(
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
  // DÉTAILS
  // ============================================================

  Widget _buildDetailsRendezVous(
    AppLocalizations t,
  ) {
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
            Text(
              t.appointmentDetails,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _detailRow(
              Icons.calendar_today,
              t.detailsDate,
              _formaterDate(rdv.dateRDV),
            ),

            _detailRow(
              Icons.access_time,
              t.time,
              '${_formaterHeure(rdv.heureDebut)} - '
              '${_formaterHeure(rdv.heureFin)}',
            ),

            _detailRow(
  Icons.category,
  t.type,
  _afficherType(rdv.typeRDV, t),
),

            _detailRow(
              Icons.title,
              t.title,
              rdv.titre,
            ),

            _detailRow(
              Icons.info_outline,
              t.status,
              _afficherStatut(rdv.statut, t),
            ),

            _detailRow(
              rdv.estFavori
                  ? Icons.star
                  : Icons.star_border,
              t.favorite,
              rdv.estFavori ? t.yes : t.no,
            ),

            if (_afficherContact(rdv).isNotEmpty)
              _detailRow(
                Icons.person,
                rdv.typeRDV == 'Medical'
                    ? t.detailsDoctor
                    : rdv.typeRDV == 'Professionnel'
                        ? t.detailsProfessional
                        : t.detailsContactGeneric,
                _afficherContact(rdv),
              ),

            if (rdv.lieu != null &&
                rdv.lieu!.trim().isNotEmpty)
              _detailRow(
                Icons.location_on,
                t.detailsPlace,
                rdv.lieu!,
              ),

            if (rdv.description != null &&
                rdv.description!.trim().isNotEmpty)
              _detailRow(
                Icons.description,
                t.detailsDescription,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: widget.appSettings.themeColor,
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
  // TABLE
  // ============================================================

  Widget _buildRendezVousTable(
    AppLocalizations t,
  ) {
    final rdvs = rendezVousDuJour;

    if (rdvs.isEmpty) {
      return Center(
        child: Text(
          t.noAppointmentsForDate,
          style: const TextStyle(
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
            widget.appSettings.themeColor,
          ),

          headingTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),

          columns: [
            DataColumn(label: Text(t.date)),
            DataColumn(label: Text(t.start)),
            DataColumn(label: Text(t.end)),
            DataColumn(label: Text(t.type)),
            DataColumn(label: Text(t.title)),
            DataColumn(label: Text(t.contact)),
            DataColumn(label: Text(t.location)),
            DataColumn(label: Text(t.description)),
            DataColumn(label: Text(t.favorite)),
            DataColumn(label: Text(t.status)),
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
                  Text(_formaterDate(rdv.dateRDV)),
                ),

                DataCell(
                  Text(_formaterHeure(rdv.heureDebut)),
                ),

                DataCell(
                  Text(_formaterHeure(rdv.heureFin)),
                ),

                DataCell(
  Text(
    _afficherType(rdv.typeRDV, t),
  ),
),

                DataCell(
                  SizedBox(
                    width: 160,
                    child: Text(
                      rdv.titre,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                DataCell(
                  SizedBox(
                    width: 230,
                    child: Text(
                      _afficherContact(rdv),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                DataCell(
                  SizedBox(
                    width: 150,
                    child: Text(
                      rdv.lieu ?? '',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                DataCell(
                  SizedBox(
                    width: 250,
                    child: Text(
                      rdv.description ?? '',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                // FAVORI
                DataCell(
                  IconButton(
                    tooltip: rdv.estFavori
                        ? t.removeFromFavorites
                        : t.addToFavorites,
                    icon: Icon(
                      rdv.estFavori
                          ? Icons.star
                          : Icons.star_border,
                      color: rdv.estFavori
                          ? Colors.amber
                          : Colors.grey,
                    ),
                    onPressed: () {
                      _changerFavori(rdv, t);
                    },
                  ),
                ),

                // STATUT
                DataCell(
                  InkWell(
                    onTap: () {
                      _afficherMenuStatut(rdv, t);
                    },
                    borderRadius:
                        BorderRadius.circular(20),
                    child: _buildStatutBadge(
                      rdv.statut,
                      t,
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
          appSettings: widget.appSettings,
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

  Future<void> _modifierRendezVous(
    AppLocalizations t,
  ) async {
    if (_selectedRendezVous == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.selectAppointment),
        ),
      );

      return;
    }

    final resultat = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RendezVousEditPage(
          rendezVous: _selectedRendezVous,
          appSettings: widget.appSettings,
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

  Future<void> _supprimerRendezVous(
    AppLocalizations t,
  ) async {
    if (_selectedRendezVous == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.selectAppointment),
        ),
      );

      return;
    }

    final rdv = _selectedRendezVous!;

    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.deleteAppointment),

          content: Text(
            '${t.confirmDeleteAppointment} '
            '"${rdv.titre}" ?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text(t.cancel),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(t.deleteButton),
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
                t.errorDeleting,
          ),
        ),
      );

      return;
    }

    setState(() {
      _selectedRendezVous = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.deletedSuccessfully),
      ),
    );
  }

  // ============================================================
  // INTERFACE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    final dateSelectionnee =
        _selectedDay ?? DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.calendar,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor:
            widget.appSettings.themeColor,

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
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: _buildCalendrier(),
                    ),

                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      color:
                          const Color(0xFFE8F7F7),
                      child: Text(
                        '${t.todayAppointments} '
                        '${DateFormat('dd/MM/yyyy').format(dateSelectionnee)}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    _buildRendezVousTable(t),

                    _buildDetailsRendezVous(t),

                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(
                        12,
                        6,
                        12,
                        12,
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(
                          12,
                          6,
                          12,
                          12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child:
                                  ElevatedButton.icon(
                                onPressed:
                                    _ajouterRendezVous,
                                icon: const Icon(
                                  Icons.add,
                                  size: 18,
                                ),
                                label: Text(
                                  t.addButton,
                                  style:
                                      const TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                                style:
                                    ElevatedButton
                                        .styleFrom(
                                  backgroundColor:
                                      widget
                                          .appSettings
                                          .themeColor,
                                  foregroundColor:
                                      Colors.white,
                                  minimumSize:
                                      const Size(
                                    0,
                                    42,
                                  ),
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 4,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 6),

                            Expanded(
                              child:
                                  ElevatedButton.icon(
                                onPressed: () {
                                  _modifierRendezVous(
                                    t,
                                  );
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  size: 18,
                                ),
                                label: Text(
                                  t.editButton,
                                  style:
                                      const TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                                style:
                                    ElevatedButton
                                        .styleFrom(
                                  minimumSize:
                                      const Size(
                                    0,
                                    42,
                                  ),
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 4,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 6),

                            Expanded(
                              child:
                                  ElevatedButton.icon(
                                onPressed: () {
                                  _supprimerRendezVous(
                                    t,
                                  );
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  size: 18,
                                ),
                                label: Text(
                                  t.deleteButton,
                                  style:
                                      const TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                                style:
                                    ElevatedButton
                                        .styleFrom(
                                  backgroundColor:
                                      Colors.red,
                                  foregroundColor:
                                      Colors.white,
                                  minimumSize:
                                      const Size(
                                    0,
                                    42,
                                  ),
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 4,
                                  ),
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
