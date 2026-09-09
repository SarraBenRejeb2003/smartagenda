import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/database_helper.dart';
import '../../models/docteur.dart';
import '../../models/professionnel.dart';
import '../../models/rendez_vous.dart';

class RendezVousEditPage extends StatefulWidget {
  final RendezVous? rendezVous;
  final DateTime? initialDate;

  const RendezVousEditPage({
    super.key,
    this.rendezVous,
    this.initialDate,
  });

  @override
  State<RendezVousEditPage> createState() => _RendezVousEditPageState();
}

class _RendezVousEditPageState extends State<RendezVousEditPage> {
  final _formKey = GlobalKey<FormState>();

  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController();
  final TextEditingController _lieuController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  TimeOfDay _heureDebut = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _heureFin = const TimeOfDay(hour: 10, minute: 0);

  String _typeRDV = 'Professionnel';

  List<Professionnel> _professionnels = [];
  List<Docteur> _docteurs = [];

  int? _selectedProfessionnelId;
  int? _selectedDocteurId;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _selectedDate = widget.rendezVous != null
        ? _dateFromString(widget.rendezVous!.dateRDV)
        : widget.initialDate ?? DateTime.now();

    if (widget.rendezVous != null) {
      final rdv = widget.rendezVous!;

      _typeRDV = rdv.typeRDV;

      _titreController.text = rdv.titre;
      _descriptionController.text = rdv.description ?? '';
      _lieuController.text = rdv.lieu ?? '';

      _heureDebut = _timeFromString(rdv.heureDebut);
      _heureFin = _timeFromString(rdv.heureFin);

      _selectedProfessionnelId = rdv.idProfessionnel;
      _selectedDocteurId = rdv.idDocteur;
    }

    _loadData();
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _lieuController.dispose();
    super.dispose();
  }

  // ============================================================
  // CHARGEMENT DES PROFESSIONNELS ET DOCTEURS
  // ============================================================

  Future<void> _loadData() async {
    try {
      final professionnels =
          await _databaseHelper.getProfessionnels();

      final docteurs = await _databaseHelper.getDocteurs();

      if (!mounted) return;

      setState(() {
        _professionnels = professionnels;
        _docteurs = docteurs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors du chargement des données : $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // DATE
  // ============================================================

  DateTime _dateFromString(String date) {
    try {
      return DateFormat('dd/MM/yyyy').parse(date);
    } catch (_) {
      try {
        return DateTime.parse(date);
      } catch (_) {
        return DateTime.now();
      }
    }
  }

  String _dateToString(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // ============================================================
  // HEURE
  // ============================================================

  TimeOfDay _timeFromString(String time) {
    try {
      final parts = time.split(':');

      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (_) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  String _timeToString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  int _timeToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  // ============================================================
  // CHOISIR UNE DATE
  // ============================================================

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('fr', 'FR'),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  // ============================================================
  // CHOISIR L'HEURE DE DÉBUT
  // ============================================================

  Future<void> _selectHeureDebut() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _heureDebut,
    );

    if (time != null) {
      setState(() {
        _heureDebut = time;
      });
    }
  }

  // ============================================================
  // CHOISIR L'HEURE DE FIN
  // ============================================================

  Future<void> _selectHeureFin() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _heureFin,
    );

    if (time != null) {
      setState(() {
        _heureFin = time;
      });
    }
  }

  // ============================================================
  // CHANGEMENT DU TYPE DE RENDEZ-VOUS
  // ============================================================

  void _changeType(String? value) {
    if (value == null) return;

    setState(() {
      _typeRDV = value;

      // Professionnel :
      // on garde le professionnel et on supprime le docteur
      if (_typeRDV == 'Professionnel') {
        _selectedDocteurId = null;
      }

      // Médical :
      // on garde le docteur et on supprime le professionnel
      else if (_typeRDV == 'Medical') {
        _selectedProfessionnelId = null;
      }

      // Privé :
      // aucun professionnel et aucun docteur
      else if (_typeRDV == 'Prive') {
        _selectedProfessionnelId = null;
        _selectedDocteurId = null;
      }
    });
  }

  // ============================================================
  // SAUVEGARDER
  // ============================================================

  Future<void> _saveRendezVous() async {
    if (_isSaving) return;

    // Validation des champs classiques
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ========================================================
    // VALIDATION DE L'HEURE
    // ========================================================

    final debutMinutes = _timeToMinutes(_heureDebut);
    final finMinutes = _timeToMinutes(_heureFin);

    if (finMinutes <= debutMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'L’heure de fin doit être supérieure à l’heure de début.',
          ),
        ),
      );
      return;
    }

    // ========================================================
    // VALIDATION SELON LE TYPE
    // ========================================================

    if (_typeRDV == 'Professionnel') {
      if (_selectedProfessionnelId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Veuillez choisir un professionnel.',
            ),
          ),
        );
        return;
      }
    }

    if (_typeRDV == 'Medical') {
      if (_selectedDocteurId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Veuillez choisir un docteur.',
            ),
          ),
        );
        return;
      }
    }

    // Pour un rendez-vous privé, on ne garde aucun ID
    if (_typeRDV == 'Prive') {
      _selectedProfessionnelId = null;
      _selectedDocteurId = null;
    }

    // ========================================================
    // VÉRIFICATION DU CHEVAUCHEMENT
    // ========================================================

    final dateString = _dateToString(_selectedDate);
    final heureDebutString = _timeToString(_heureDebut);
    final heureFinString = _timeToString(_heureFin);

    final hasOverlap =
    await _databaseHelper.hasRendezVousOverlap(
  dateRDV: dateString,
  heureDebut: heureDebutString,
  heureFin: heureFinString,
  excludeId: widget.rendezVous?.idRendezVous,
);

if (hasOverlap) {
  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        '⚠️ Le créneau $heureDebutString - $heureFinString '
        'est déjà occupé par un autre rendez-vous.',
      ),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
    ),
  );

  return;
}

    // ========================================================
    // CRÉATION DU RENDEZ-VOUS
    // ========================================================

    final rdv = RendezVous(
      idRendezVous: widget.rendezVous?.idRendezVous,
      dateRDV: dateString,
      heureDebut: heureDebutString,
      heureFin: heureFinString,
      typeRDV: _typeRDV,
      titre: _titreController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      lieu: _lieuController.text.trim().isEmpty
          ? null
          : _lieuController.text.trim(),
      idProfessionnel: _selectedProfessionnelId,
      idDocteur: _selectedDocteurId,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      // ======================================================
      // MODIFICATION
      // ======================================================

      if (widget.rendezVous != null) {
        await _databaseHelper.updateRendezVous(rdv);
      }

      // ======================================================
      // AJOUT
      // ======================================================

      else {
        await _databaseHelper.insertRendezVous(rdv);
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de l’enregistrement : $e',
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.rendezVous == null
              ? 'Ajouter un rendez-vous'
              : 'Modifier le rendez-vous',
        ),
        backgroundColor: const Color(0xFF159E9E),
        foregroundColor: Colors.white,
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // ==================================================
                    // TYPE
                    // ==================================================

                    DropdownButtonFormField<String>(
                      value: _typeRDV,
                      decoration: const InputDecoration(
                        labelText: 'Type de rendez-vous',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Professionnel',
                          child: Text('Professionnel'),
                        ),
                        DropdownMenuItem(
                          value: 'Medical',
                          child: Text('Médical'),
                        ),
                        DropdownMenuItem(
                          value: 'Prive',
                          child: Text('Privé'),
                        ),
                      ],
                      onChanged: _changeType,
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // PROFESSIONNEL
                    // AFFICHÉ UNIQUEMENT POUR LE TYPE PROFESSIONNEL
                    // ==================================================

                    if (_typeRDV == 'Professionnel')
                      DropdownButtonFormField<int>(
                        value: _selectedProfessionnelId,
                        decoration: const InputDecoration(
                          labelText: 'Professionnel *',
                          hintText: 'Choisir un professionnel',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business_center),
                        ),
                        items: _professionnels.map((professionnel) {
                          final details = [
                            professionnel.societe,
                            professionnel.fonction,
                          ]
                              .where(
                                (element) =>
                                    element != null &&
                                    element.trim().isNotEmpty,
                              )
                              .join(' - ');

                          return DropdownMenuItem<int>(
                            value: professionnel.idProfessionnel,
                            child: Text(
                              details.isEmpty
                                  ? professionnel.nom
                                  : '${professionnel.nom} - $details',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedProfessionnelId = value;
                          });
                        },
                        validator: (value) {
                          if (_typeRDV == 'Professionnel' &&
                              value == null) {
                            return 'Veuillez choisir un professionnel';
                          }
                          return null;
                        },
                      ),

                    // ==================================================
                    // MESSAGE SI AUCUN PROFESSIONNEL
                    // ==================================================

                    if (_typeRDV == 'Professionnel' &&
                        _professionnels.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Aucun professionnel enregistré. '
                          'Ajoutez d’abord un professionnel.',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),

                    // ==================================================
                    // DOCTEUR
                    // AFFICHÉ UNIQUEMENT POUR LE TYPE MÉDICAL
                    // ==================================================

                    if (_typeRDV == 'Medical')
                      DropdownButtonFormField<int>(
                        value: _selectedDocteurId,
                        decoration: const InputDecoration(
                          labelText: 'Docteur *',
                          hintText: 'Choisir un docteur',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.medical_services),
                        ),
                        items: _docteurs.map((docteur) {
                          final details =
                              docteur.specialite?.trim() ?? '';

                          return DropdownMenuItem<int>(
                            value: docteur.idDocteur,
                            child: Text(
                              details.isEmpty
                                  ? docteur.nom
                                  : '${docteur.nom} - $details',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDocteurId = value;
                          });
                        },
                        validator: (value) {
                          if (_typeRDV == 'Medical' &&
                              value == null) {
                            return 'Veuillez choisir un docteur';
                          }
                          return null;
                        },
                      ),

                    // ==================================================
                    // MESSAGE SI AUCUN DOCTEUR
                    // ==================================================

                    if (_typeRDV == 'Medical' && _docteurs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Aucun docteur enregistré. '
                          'Ajoutez d’abord un docteur.',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // TITRE
                    // ==================================================

                    TextFormField(
                      controller: _titreController,
                      decoration: const InputDecoration(
                        labelText: 'Titre *',
                        hintText: 'Exemple : Réunion',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Veuillez saisir un titre';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // DATE
                    // ==================================================

                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat(
                            'EEEE dd MMMM yyyy',
                            'fr_FR',
                          ).format(_selectedDate),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // HEURE DÉBUT
                    // ==================================================

                    InkWell(
                      onTap: _selectHeureDebut,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Heure de début',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(
                          _timeToString(_heureDebut),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // HEURE FIN
                    // ==================================================

                    InkWell(
                      onTap: _selectHeureFin,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Heure de fin',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(
                          _timeToString(_heureFin),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // LIEU
                    // ==================================================

                    TextFormField(
                      controller: _lieuController,
                      decoration: const InputDecoration(
                        labelText: 'Lieu',
                        hintText: 'Exemple : Bureau / Cabinet',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // DESCRIPTION
                    // ==================================================

                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Ajouter une description...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                        alignLabelWithHint: true,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // BOUTON ENREGISTRER
                    // ==================================================

                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed:
                            _isSaving ? null : _saveRendezVous,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          _isSaving
                              ? 'Enregistrement...'
                              : 'Enregistrer',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF159E9E),
                          foregroundColor: Colors.white,
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