import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../database/database_helper.dart';
import '../../models/rendez_vous.dart';
import '../../models/professionnel.dart';
import '../../models/docteur.dart';
import '../rendez_vous/rendez_vous_edit_page.dart';

class CalendrierPage extends StatefulWidget {
  const CalendrierPage({super.key});

  @override
  State<CalendrierPage> createState() => _CalendrierPageState();
}

class _CalendrierPageState extends State<CalendrierPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  RendezVous? _selectedRendezVous;

  List<RendezVous> rendezVous = [];
  List<Professionnel> _professionnels = [];
  List<Docteur> _docteurs = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _selectedDay = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    _chargerDonnees();
  }

  // ============================================================
  // CHARGEMENT DES DONNÉES
  // ============================================================

  Future<void> _chargerDonnees() async {
    setState(() {
      isLoading = true;
    });

    try {
      final resultatsRdv = await _databaseHelper.getRendezVous();
      final resultatsProfessionnels =
          await _databaseHelper.getProfessionnels();
      final resultatsDocteurs = await _databaseHelper.getDocteurs();

      if (!mounted) return;

      setState(() {
        rendezVous = resultatsRdv;
        _professionnels = resultatsProfessionnels;
        _docteurs = resultatsDocteurs;
        isLoading = false;

        // Si le rendez-vous sélectionné existe toujours,
        // on le retrouve après le rechargement.
        if (_selectedRendezVous != null) {
          final id = _selectedRendezVous!.idRendezVous;

          try {
            _selectedRendezVous = rendezVous.firstWhere(
              (rdv) => rdv.idRendezVous == id,
            );
          } catch (_) {
            _selectedRendezVous = null;
          }
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement : $e'),
        ),
      );
    }
  }

  // ============================================================
  // GESTION DES DATES
  // ============================================================

  DateTime? _convertirDate(String date) {
    // Format principal : yyyy-MM-dd
    try {
      return DateTime.parse(date);
    } catch (_) {}

    // Ancien format éventuel : dd/MM/yyyy
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

  List<RendezVous> get rendezVousDuJour {
    if (_selectedDay == null) {
      return [];
    }

    return rendezVous
        .where((rdv) => _memeJour(rdv, _selectedDay!))
        .toList();
  }

  // ============================================================
  // RECHERCHE PROFESSIONNEL / DOCTEUR
  // ============================================================

  Professionnel? _getProfessionnel(int? id) {
    if (id == null) {
      return null;
    }

    for (final professionnel in _professionnels) {
      if (professionnel.idProfessionnel == id) {
        return professionnel;
      }
    }

    return null;
  }

  Docteur? _getDocteur(int? id) {
    if (id == null) {
      return null;
    }

    for (final docteur in _docteurs) {
      if (docteur.idDocteur == id) {
        return docteur;
      }
    }

    return null;
  }

  // ============================================================
  // AFFICHAGE DU CONTACT
  // ============================================================

  String _afficherContact(RendezVous rdv) {
    if (rdv.typeRDV == 'Professionnel') {
      final professionnel = _getProfessionnel(rdv.idProfessionnel);

      if (professionnel == null) {
        return '';
      }

      final details = <String>[];

      if (professionnel.societe != null &&
          professionnel.societe!.trim().isNotEmpty) {
        details.add(professionnel.societe!.trim());
      }

      if (professionnel.fonction != null &&
          professionnel.fonction!.trim().isNotEmpty) {
        details.add(professionnel.fonction!.trim());
      }

      if (details.isEmpty) {
        return professionnel.nom;
      }

      return '${professionnel.nom} - ${details.join(' - ')}';
    }

    if (rdv.typeRDV == 'Medical') {
      final docteur = _getDocteur(rdv.idDocteur);

      if (docteur == null) {
        return '';
      }

      if (docteur.specialite != null &&
          docteur.specialite!.trim().isNotEmpty) {
        return '${docteur.nom} - ${docteur.specialite!.trim()}';
      }

      return docteur.nom;
    }

    return 'Privé';
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
        return isSameDay(_selectedDay, day);
      },

      eventLoader: (day) {
        return rendezVous.where((rdv) {
          return _memeJour(rdv, day);
        }).toList();
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
  // INFORMATIONS DU RENDEZ-VOUS SÉLECTIONNÉ
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

            if (rdv.lieu != null && rdv.lieu!.trim().isNotEmpty)
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
        crossAxisAlignment: CrossAxisAlignment.start,
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

          headingRowColor: WidgetStateProperty.all(
            const Color(0xFF159E9E),
          ),

          headingTextStyle: const TextStyle(
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
                    _formaterDate(rdv.dateRDV),
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
          initialDate: _selectedDay ?? _focusedDay,
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

    final confirmation = await showDialog<bool>(
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

    try {
      await _databaseHelper.deleteRendezVous(
        rdv.idRendezVous!,
      );

      if (!mounted) return;

      setState(() {
        _selectedRendezVous = null;
      });

      await _chargerDonnees();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Rendez-vous supprimé avec succès.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de la suppression : $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // INTERFACE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final dateSelectionnee = _selectedDay ?? DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendrier',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF159E9E),
        foregroundColor: Colors.white,

        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _chargerDonnees,
          ),
        ],
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
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

                Expanded(
                  child: _buildRendezVousTable(),
                ),

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
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _ajouterRendezVous,
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF159E9E),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _modifierRendezVous,
                          icon: const Icon(Icons.edit),
                          label: const Text('Modifier'),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _supprimerRendezVous,
                          icon: const Icon(Icons.delete),
                          label: const Text('Supprimer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
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
}