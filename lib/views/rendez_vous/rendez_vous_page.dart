import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app_localizations.dart';
import '../../app_settings.dart';
import '../../models/rendez_vous.dart';
import '../../models/professionnel.dart';
import '../../models/docteur.dart';
import '../../viewmodels/rendez_vous_viewmodel.dart';
import 'rendez_vous_edit_page.dart';

class RendezVousPage extends StatefulWidget {
  final AppSettings appSettings;

  const RendezVousPage({super.key, required this.appSettings});

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
        builder: (_) => RendezVousEditPage(appSettings: widget.appSettings),
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
    final t = AppLocalizations.of(context);

    if (selectedIndex == null) {
      _afficherMessage(t.selectAppointment);
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
          appSettings: widget.appSettings,
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
    final t = AppLocalizations.of(context);

    if (selectedIndex == null) {
      _afficherMessage(t.selectAppointment);
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
          title: Text(t.confirmation),
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
              child: Text(t.delete),
            ),
          ],
        );
      },
    );

    if (confirmation != true) {
      return;
    }

    final success = await _viewModel.supprimerRendezVous(rdv.idRendezVous!);

    if (!mounted) return;

    if (success) {
      setState(() {
        selectedIndex = null;
      });

      _afficherMessage(t.deletedSuccessfully);
    } else if (_viewModel.errorMessage != null) {
      _afficherMessage(_viewModel.errorMessage!);

      _viewModel.clearError();
    }
  }

  // ============================================================
  // FAVORI
  // ============================================================

  Future<void> _changerFavori(RendezVous rdv) async {
    final t = AppLocalizations.of(context);

    if (rdv.idRendezVous == null) {
      return;
    }

    final success = await _viewModel.modifierFavori(
      rdv.idRendezVous!,
      !rdv.estFavori,
    );

    if (!mounted) return;

    if (!success && _viewModel.errorMessage != null) {
      _afficherMessage(_viewModel.errorMessage!);

      _viewModel.clearError();
    } else if (success) {
      _afficherMessage(rdv.estFavori ? t.favoriteRemoved : t.favoriteAdded);
    }
  }

  // ============================================================
  // STATUT
  // ============================================================

  Future<void> _changerStatut(RendezVous rdv, String nouveauStatut) async {
    if (rdv.idRendezVous == null) {
      return;
    }

    if (rdv.statut == nouveauStatut) {
      return;
    }

    final success = await _viewModel.modifierStatut(
      rdv.idRendezVous!,
      nouveauStatut,
    );

    if (!mounted) return;

    if (!success && _viewModel.errorMessage != null) {
      _afficherMessage(_viewModel.errorMessage!);

      _viewModel.clearError();
    } else if (success) {
      _afficherMessage(AppLocalizations.of(context).statusModified);
    }
  }

  // ============================================================
  // AFFICHER LE MENU DU STATUT
  // ============================================================

  Future<void> _afficherMenuStatut(BuildContext context, RendezVous rdv) async {
    final t = AppLocalizations.of(context);

    final selectedStatus = await showModalBottomSheet<String>(
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

              // PLANIFIÉ
              ListTile(
                leading: const Icon(Icons.schedule, color: Colors.blue),
                title: Text(t.scheduled),
                trailing: rdv.statut == 'Planifie'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  Navigator.pop(context, 'Planifie');
                },
              ),

              // TERMINÉ
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(t.completed),
                trailing: rdv.statut == 'Termine'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  Navigator.pop(context, 'Termine');
                },
              ),

              // ANNULÉ
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
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

    if (selectedStatus != null) {
      await _changerStatut(rdv, selectedStatus);
    }
  }

  // ============================================================
  // AFFICHER LE STATUT
  // ============================================================

  String _afficherStatut(String statut) {
    final t = AppLocalizations.of(context);

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

  // ============================================================
  // COULEUR DU STATUT
  // ============================================================

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

  // ============================================================
  // MESSAGE
  // ============================================================

  void _afficherMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formaterDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);

      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (_) {}

    try {
      final parsedDate = DateFormat('dd/MM/yyyy').parse(date);

      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (_) {}

    return date;
  }

  // ============================================================
  // FORMAT HEURE
  // ============================================================

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

  // ============================================================
  // TYPE
  // ============================================================

 
String _afficherType(String type) {
  final t = AppLocalizations.of(context);

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
// AFFICHER LE CONTACT
// ============================================================

String _afficherContact(RendezVous rdv) {
  final t = AppLocalizations.of(context);

  if (rdv.typeRDV == 'Professionnel') {
    final Professionnel? professionnel = _viewModel.getProfessionnel(
      rdv.idProfessionnel,
    );

    if (professionnel == null) {
      return '';
    }

    final details = <String>[];

    if (professionnel.societe.trim().isNotEmpty) {
      details.add(professionnel.societe.trim());
    }

    if (professionnel.fonction.trim().isNotEmpty) {
      details.add(professionnel.fonction.trim());
    }

    if (details.isEmpty) {
      return professionnel.nom;
    }

    return '${professionnel.nom} - '
        '${details.join(' - ')}';
  }

  if (rdv.typeRDV == 'Medical') {
    final Docteur? docteur = _viewModel.getDocteur(
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

  // Private appointment
  if (rdv.typeRDV == 'Private' ||
      rdv.typeRDV == 'Prive' ||
      rdv.typeRDV == 'Privé') {
    return t.privateAppointment;
  }

  return '';
}


  // ============================================================
  // DÉTAILS DU RENDEZ-VOUS
  // ============================================================

  Widget _buildDetailsRendezVous() {
    final t = AppLocalizations.of(context);

    if (selectedIndex == null) {
      return const SizedBox.shrink();
    }

    final rendezVous = _viewModel.rendezVous;

    if (selectedIndex! >= rendezVous.length) {
      return const SizedBox.shrink();
    }

    final rdv = rendezVous[selectedIndex!];

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_note, color: widget.appSettings.themeColor),
                const SizedBox(width: 8),
                Text(
                  t.appointmentDetails,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            _detailRow(
              Icons.calendar_today,
              t.date,
              _formaterDate(rdv.dateRDV),
            ),

            _detailRow(
              Icons.access_time,
              t.time,
              '${_formaterHeure(rdv.heureDebut)} - '
              '${_formaterHeure(rdv.heureFin)}',
            ),

            _detailRow(Icons.category, t.type, _afficherType(rdv.typeRDV)),

            _detailRow(Icons.title, t.title, rdv.titre),

            _detailRow(Icons.flag, t.status, _afficherStatut(rdv.statut)),

            _detailRow(Icons.star, t.favorite, rdv.estFavori ? t.yes : t.no),

            if (_afficherContact(rdv).isNotEmpty)
              _detailRow(
                Icons.person,
                rdv.typeRDV == 'Medical'
                    ? t.doctor
                    : rdv.typeRDV == 'Professionnel'
                    ? t.professional
                    : t.contact,
                _afficherContact(rdv),
              ),

            if (rdv.lieu != null && rdv.lieu!.trim().isNotEmpty)
              _detailRow(Icons.location_on, t.location, rdv.lieu!),

            if (rdv.description != null && rdv.description!.trim().isNotEmpty)
              _detailRow(Icons.description, t.description, rdv.description!),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LIGNE DE DÉTAIL
  // ============================================================

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: widget.appSettings.themeColor),
          const SizedBox(width: 10),
          SizedBox(
            width: 105,
            child: Text(
              '$label :',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // ============================================================
  // BADGE STATUT
  // ============================================================

  Widget _buildStatutBadge(RendezVous rdv) {
    final color = _couleurStatut(rdv.statut);

    return InkWell(
      onTap: () {
        _afficherMenuStatut(context, rdv);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              rdv.statut == 'Planifie'
                  ? Icons.schedule
                  : rdv.statut == 'Termine'
                  ? Icons.check_circle
                  : Icons.cancel,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 5),
            Text(
              _afficherStatut(rdv.statut),
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TABLEAU
  // ============================================================

  Widget _buildTableau() {
    final t = AppLocalizations.of(context);
    final rendezVous = _viewModel.rendezVous;

    if (rendezVous.isEmpty) {
      return Center(
        child: Text(
          t.noAppointmentsRecorded,
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 30,
          headingRowColor: WidgetStateProperty.all(
            widget.appSettings.themeColor.withOpacity(0.15),
          ),
          columns: [
            DataColumn(
              label: Text(
                t.favorite,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                t.status,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                t.date,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                t.start,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                t.end,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                t.type,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                t.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                t.contact,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                t.location,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                t.description,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: List.generate(rendezVous.length, (index) {
            final rdv = rendezVous[index];

            final isSelected = selectedIndex == index;

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
                // FAVORI
                DataCell(
                  IconButton(
                    tooltip: rdv.estFavori
                        ? t.removeFromFavorites
                        : t.addToFavorites,
                    onPressed: () {
                      _changerFavori(rdv);
                    },
                    icon: Icon(
                      rdv.estFavori ? Icons.star : Icons.star_border,
                      color: rdv.estFavori ? Colors.amber : Colors.grey,
                    ),
                  ),
                ),

                // STATUT
                DataCell(_buildStatutBadge(rdv)),

                // DATE
                DataCell(Text(_formaterDate(rdv.dateRDV))),

                // DÉBUT
                DataCell(Text(_formaterHeure(rdv.heureDebut))),

                // FIN
                DataCell(Text(_formaterHeure(rdv.heureFin))),

                // TYPE
                DataCell(Text(_afficherType(rdv.typeRDV))),

                // TITRE
                DataCell(
                  SizedBox(
                    width: 160,
                    child: Text(rdv.titre, overflow: TextOverflow.ellipsis),
                  ),
                ),

                // CONTACT
                DataCell(
                  SizedBox(
                    width: 230,
                    child: Text(
                      _afficherContact(rdv),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                // LIEU
                DataCell(
                  SizedBox(
                    width: 150,
                    child: Text(
                      rdv.lieu ?? '',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                // DESCRIPTION
                DataCell(
                  SizedBox(
                    width: 250,
                    child: Text(
                      rdv.description ?? '',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ============================================================
  // INTERFACE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.appointments,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: widget.appSettings.themeColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _chargerDonnees,
          ),
        ],
      ),

      body: Container(
        width: double.infinity,
        color: Colors.white,
        child: _viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // ==================================================
                  // TABLEAU
                  // ==================================================

                  Expanded(child: _buildTableau()),

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
                      alignment: WrapAlignment.center,
                      children: [
                        // NOUVEAU
                        ElevatedButton.icon(
                          onPressed: _nouveauRendezVous,
                          icon: const Icon(Icons.add),
                          label: Text(t.newAppointment),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.appSettings.themeColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                        ),

                        // MODIFIER
                        ElevatedButton.icon(
                          onPressed: _modifierRendezVous,
                          icon: const Icon(Icons.edit),
                          label: Text(t.edit),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                        ),

                        // SUPPRIMER
                        ElevatedButton.icon(
                          onPressed: _supprimerRendezVous,
                          icon: const Icon(Icons.delete),
                          label: Text(t.delete),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
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
