import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/docteur.dart';
import '../../models/professionnel.dart';
import '../../models/rendez_vous.dart';
import '../../viewmodels/rendez_vous_viewmodel.dart';

class RendezVousEditPage extends StatefulWidget {
  final RendezVous? rendezVous;
  final DateTime? initialDate;

  const RendezVousEditPage({
    super.key,
    this.rendezVous,
    this.initialDate,
  });

  @override
  State<RendezVousEditPage> createState() =>
      _RendezVousEditPageState();
}

class _RendezVousEditPageState
    extends State<RendezVousEditPage> {
  late final RendezVousViewModel _viewModel;

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titreController;
  late TextEditingController _descriptionController;
  late TextEditingController _lieuController;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _heureDebut = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _heureFin = const TimeOfDay(hour: 10, minute: 0);

  String _typeRDV = 'Professionnel';

  int? _selectedProfessionnelId;
  int? _selectedDocteurId;

  bool get _isEditing => widget.rendezVous != null;

  @override
  void initState() {
    super.initState();

    _viewModel = RendezVousViewModel();
    _viewModel.addListener(_onViewModelChanged);

    _titreController = TextEditingController(
      text: widget.rendezVous?.titre ?? '',
    );

    _descriptionController = TextEditingController(
      text: widget.rendezVous?.description ?? '',
    );

    _lieuController = TextEditingController(
      text: widget.rendezVous?.lieu ?? '',
    );

    if (widget.rendezVous != null) {
      final rdv = widget.rendezVous!;

      _selectedDate =
          DateTime.parse(rdv.dateRDV);

      _heureDebut =
          _parseTime(rdv.heureDebut);

      _heureFin =
          _parseTime(rdv.heureFin);

      _typeRDV = rdv.typeRDV;

      _selectedProfessionnelId =
          rdv.idProfessionnel;

      _selectedDocteurId =
          rdv.idDocteur;
    } else if (widget.initialDate != null) {
      _selectedDate = widget.initialDate!;
    }

    _loadData();
  }

  void _onViewModelChanged() {
    if (!mounted) return;

    setState(() {});
  }

  Future<void> _loadData() async {
    await _viewModel.loadData();

    if (!mounted) return;

    if (_viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _viewModel.errorMessage!,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(
      _onViewModelChanged,
    );

    _viewModel.dispose();

    _titreController.dispose();
    _descriptionController.dispose();
    _lieuController.dispose();

    super.dispose();
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');

    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour =
        time.hour.toString().padLeft(2, '0');

    final minute =
        time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

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

  Future<void> _selectStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _heureDebut,
    );

    if (time != null) {
      setState(() {
        _heureDebut = time;

        final startMinutes =
            time.hour * 60 + time.minute;

        final endMinutes =
            _heureFin.hour * 60 + _heureFin.minute;

        if (endMinutes <= startMinutes) {
          _heureFin = TimeOfDay(
            hour: (time.hour + 1) % 24,
            minute: time.minute,
          );
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
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

  void _changeType(String? value) {
    if (value == null) return;

    setState(() {
      _typeRDV = value;

      if (value != 'Professionnel') {
        _selectedProfessionnelId = null;
      }

      if (value != 'Medical') {
        _selectedDocteurId = null;
      }
    });
  }

  Future<void> _saveRendezVous() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final startMinutes =
        _heureDebut.hour * 60 +
            _heureDebut.minute;

    final endMinutes =
        _heureFin.hour * 60 +
            _heureFin.minute;

    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'L’heure de fin doit être après l’heure de début.',
          ),
        ),
      );

      return;
    }

    if (_typeRDV == 'Professionnel' &&
        _selectedProfessionnelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez sélectionner un professionnel.',
          ),
        ),
      );

      return;
    }

    if (_typeRDV == 'Medical' &&
        _selectedDocteurId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez sélectionner un docteur.',
          ),
        ),
      );

      return;
    }

    final rdv = RendezVous(
      idRendezVous:
          widget.rendezVous?.idRendezVous,
      dateRDV:
          DateFormat('yyyy-MM-dd')
              .format(_selectedDate),
      heureDebut:
          _formatTime(_heureDebut),
      heureFin:
          _formatTime(_heureFin),
      typeRDV: _typeRDV,
      titre: _titreController.text.trim(),
      description:
          _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
      lieu:
          _lieuController.text.trim().isEmpty
              ? null
              : _lieuController.text.trim(),
      idProfessionnel:
          _selectedProfessionnelId,
      idDocteur:
          _selectedDocteurId,
    );

    final bool success;

    if (_isEditing) {
      success =
          await _viewModel.modifierRendezVous(rdv);
    } else {
      success =
          await _viewModel.ajouterRendezVous(rdv);
    }

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _viewModel.errorMessage ??
                'Une erreur est survenue.',
          ),
        ),
      );

      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _isEditing
                ? 'Modifier le rendez-vous'
                : 'Ajouter un rendez-vous',
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? 'Modifier le rendez-vous'
              : 'Ajouter un rendez-vous',
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titreController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Veuillez saisir un titre.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _typeRDV,
                decoration: const InputDecoration(
                  labelText: 'Type de rendez-vous',
                  border: OutlineInputBorder(),
                  prefixIcon:
                      Icon(Icons.category_outlined),
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
                    value: 'Privé',
                    child: Text('Privé'),
                  ),
                ],
                onChanged: _changeType,
              ),

              const SizedBox(height: 16),

              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    prefixIcon:
                        Icon(Icons.calendar_today),
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

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectStartTime,
                      child: InputDecorator(
                        decoration:
                            const InputDecoration(
                          labelText: 'Heure début',
                          border: OutlineInputBorder(),
                          prefixIcon:
                              Icon(Icons.access_time),
                        ),
                        child: Text(
                          _formatTime(_heureDebut),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: InkWell(
                      onTap: _selectEndTime,
                      child: InputDecorator(
                        decoration:
                            const InputDecoration(
                          labelText: 'Heure fin',
                          border: OutlineInputBorder(),
                          prefixIcon:
                              Icon(Icons.access_time),
                        ),
                        child: Text(
                          _formatTime(_heureFin),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (_typeRDV == 'Professionnel')
                DropdownButtonFormField<int>(
                  value: _selectedProfessionnelId,
                  decoration:
                      const InputDecoration(
                    labelText: 'Professionnel',
                    border: OutlineInputBorder(),
                    prefixIcon:
                        Icon(Icons.business_center),
                  ),
                  items: _viewModel.professionnels
                      .map(
                        (Professionnel professionnel) {
                      return DropdownMenuItem<int>(
                        value:
                            professionnel.idProfessionnel,
                        child: Text(
                          '${professionnel.nom} - '
                          '${professionnel.societe ?? ''} '
                          '${professionnel.fonction ?? ''}',
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProfessionnelId =
                          value;
                    });
                  },
                ),

              if (_typeRDV == 'Medical')
                DropdownButtonFormField<int>(
                  value: _selectedDocteurId,
                  decoration:
                      const InputDecoration(
                    labelText: 'Docteur',
                    border: OutlineInputBorder(),
                    prefixIcon:
                        Icon(Icons.medical_services),
                  ),
                  items: _viewModel.docteurs
                      .map((Docteur docteur) {
                    return DropdownMenuItem<int>(
                      value: docteur.idDocteur,
                      child: Text(
                        '${docteur.nom} - '
                        '${docteur.specialite ?? ''}',
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDocteurId = value;
                    });
                  },
                ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _lieuController,
                decoration: const InputDecoration(
                  labelText: 'Lieu',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                    _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _viewModel.isSaving
                      ? null
                      : _saveRendezVous,
                  icon: _viewModel.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _viewModel.isSaving
                        ? 'Enregistrement...'
                        : _isEditing
                            ? 'Modifier'
                            : 'Enregistrer',
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