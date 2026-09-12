
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app_localizations.dart';
import '../../app_settings.dart';
import '../../models/docteur.dart';
import '../../models/professionnel.dart';
import '../../models/rendez_vous.dart';
import '../../viewmodels/rendez_vous_viewmodel.dart';

class RendezVousEditPage extends StatefulWidget {
  final RendezVous? rendezVous;
  final DateTime? initialDate;
  final AppSettings appSettings;

  const RendezVousEditPage({
    super.key,
    this.rendezVous,
    this.initialDate,
    required this.appSettings,
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

  TimeOfDay _heureDebut =
      const TimeOfDay(hour: 9, minute: 0);

  TimeOfDay _heureFin =
      const TimeOfDay(hour: 10, minute: 0);

  String _typeRDV = 'Professionnel';

  int? _selectedProfessionnelId;
  int? _selectedDocteurId;

  String _statut = 'Planifie';

  bool _estFavori = false;

  bool get _isEditing =>
      widget.rendezVous != null;

  @override
  void initState() {
    super.initState();

    _viewModel = RendezVousViewModel();
    _viewModel.addListener(
      _onViewModelChanged,
    );

    _titreController = TextEditingController(
      text: widget.rendezVous?.titre ?? '',
    );

    _descriptionController =
        TextEditingController(
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

      _statut = rdv.statut;

      _estFavori = rdv.estFavori;
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
    final dateTime = DateTime(
      2000,
      1,
      1,
      time.hour,
      time.minute,
    );

    if (widget.appSettings.parametres.formatHeure ==
        '12h') {
      return DateFormat('h:mm a').format(dateTime);
    }

    return DateFormat('HH:mm').format(dateTime);
  }

  String _formatTimeForDatabase(
    TimeOfDay time,
  ) {
    final hour =
        time.hour.toString().padLeft(2, '0');

    final minute =
        time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  Future<void> _selectDate() async {
    final locale =
        Localizations.localeOf(context);

    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: locale,
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
    final t = AppLocalizations.of(context);

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
        SnackBar(
          content: Text(t.endTimeAfterStart),
        ),
      );

      return;
    }

    if (_typeRDV == 'Professionnel' &&
        _selectedProfessionnelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.selectProfessional,
          ),
        ),
      );

      return;
    }

    if (_typeRDV == 'Medical' &&
        _selectedDocteurId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.selectDoctor),
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
          _formatTimeForDatabase(
        _heureDebut,
      ),

      heureFin:
          _formatTimeForDatabase(
        _heureFin,
      ),

      typeRDV: _typeRDV,

      titre:
          _titreController.text.trim(),

      description:
          _descriptionController.text
                  .trim()
                  .isEmpty
              ? null
              : _descriptionController.text
                  .trim(),

      lieu:
          _lieuController.text.trim().isEmpty
              ? null
              : _lieuController.text.trim(),

      idProfessionnel:
          _selectedProfessionnelId,

      idDocteur:
          _selectedDocteurId,

      statut: _statut,

      estFavori: _estFavori,
    );

    final bool success;

    if (_isEditing) {
      success =
          await _viewModel.modifierRendezVous(
        rdv,
      );
    } else {
      success =
          await _viewModel.ajouterRendezVous(
        rdv,
      );
    }

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _viewModel.errorMessage ??
                t.unexpectedError,
          ),
        ),
      );

      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    final locale =
        Localizations.localeOf(context);

    if (_viewModel.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _isEditing
                ? t.editAppointment
                : t.addAppointment,
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
              ? t.editAppointment
              : t.addAppointment,
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
              // -------------------------
              // TITRE
              // -------------------------
              TextFormField(
                controller: _titreController,

                decoration:
                    InputDecoration(
                  labelText: t.title,
                  border:
                      const OutlineInputBorder(),
                  prefixIcon:
                      const Icon(Icons.title),
                ),

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return t.enterTitle;
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // -------------------------
              // TYPE
              // -------------------------
              DropdownButtonFormField<String>(
                initialValue: _typeRDV,

                decoration:
                    InputDecoration(
                  labelText: t.appointmentType,
                  border:
                      const OutlineInputBorder(),
                  prefixIcon: const Icon(
                    Icons.category_outlined,
                  ),
                ),

                items: [
                  DropdownMenuItem(
                    value: 'Professionnel',
                    child: Text(
                      t.professional,
                    ),
                  ),

                  DropdownMenuItem(
                    value: 'Medical',
                    child: Text(
                      t.medical,
                    ),
                  ),

                  DropdownMenuItem(
                    value: 'Privé',
                    child: Text(
                      t.privateAppointment,
                    ),
                  ),
                ],

                onChanged: _changeType,
              ),

              const SizedBox(height: 16),

              // -------------------------
              // STATUT
              // -------------------------
              DropdownButtonFormField<String>(
                initialValue: _statut,

                decoration:
                    InputDecoration(
                  labelText: t.status,
                  border:
                      const OutlineInputBorder(),
                  prefixIcon: const Icon(
                    Icons.flag_outlined,
                  ),
                ),

                items: [
                  DropdownMenuItem(
                    value: 'Planifie',
                    child: Text(
                      t.scheduled,
                    ),
                  ),

                  DropdownMenuItem(
                    value: 'Termine',
                    child: Text(
                      t.completed,
                    ),
                  ),

                  DropdownMenuItem(
                    value: 'Annule',
                    child: Text(
                      t.cancelled,
                    ),
                  ),
                ],

                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _statut = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              // -------------------------
              // DATE
              // -------------------------
              InkWell(
                onTap: _selectDate,

                child: InputDecorator(
                  decoration:
                      InputDecoration(
                    labelText: t.date,
                    border:
                        const OutlineInputBorder(),
                    prefixIcon: const Icon(
                      Icons.calendar_today,
                    ),
                  ),

                  child: Text(
                    DateFormat(
                      'EEEE dd MMMM yyyy',
                      locale.toString(),
                    ).format(_selectedDate),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // -------------------------
              // HEURES
              // -------------------------
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap:
                          _selectStartTime,

                      child: InputDecorator(
                        decoration:
                            InputDecoration(
                          labelText:
                              t.startTime,
                          border:
                              const OutlineInputBorder(),
                          prefixIcon:
                              const Icon(
                            Icons.access_time,
                          ),
                        ),

                        child: Text(
                          _formatTime(
                            _heureDebut,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: InkWell(
                      onTap:
                          _selectEndTime,

                      child: InputDecorator(
                        decoration:
                            InputDecoration(
                          labelText:
                              t.endTime,
                          border:
                              const OutlineInputBorder(),
                          prefixIcon:
                              const Icon(
                            Icons.access_time,
                          ),
                        ),

                        child: Text(
                          _formatTime(
                            _heureFin,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // -------------------------
              // PROFESSIONNEL
              // -------------------------
              if (_typeRDV ==
                  'Professionnel')
                DropdownButtonFormField<int>(
                  initialValue:
                      _selectedProfessionnelId,

                  decoration:
                      InputDecoration(
                    labelText:
                        t.professional,
                    border:
                        const OutlineInputBorder(),
                    prefixIcon: const Icon(
                      Icons.business_center,
                    ),
                  ),

                  items: _viewModel
                      .professionnels
                      .map(
                    (
                      Professionnel professionnel,
                    ) {
                      return DropdownMenuItem<int>(
                        value: professionnel
                            .idProfessionnel,

                        child: Text(
                          '${professionnel.nom} - '
                          '${professionnel.societe ?? ''} '
                          '${professionnel.fonction ?? ''}',

                          overflow:
                              TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ).toList(),

                  onChanged: (value) {
                    setState(() {
                      _selectedProfessionnelId =
                          value;
                    });
                  },
                ),

              // -------------------------
              // DOCTEUR
              // -------------------------
              if (_typeRDV == 'Medical')
                DropdownButtonFormField<int>(
                  initialValue:
                      _selectedDocteurId,

                  decoration:
                      InputDecoration(
                    labelText:
                        t.doctor,
                    border:
                        const OutlineInputBorder(),
                    prefixIcon: const Icon(
                      Icons.medical_services,
                    ),
                  ),

                  items: _viewModel
                      .docteurs
                      .map(
                    (Docteur docteur) {
                      return DropdownMenuItem<int>(
                        value:
                            docteur.idDocteur,

                        child: Text(
                          '${docteur.nom} - '
                          '${docteur.specialite ?? ''}',

                          overflow:
                              TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ).toList(),

                  onChanged: (value) {
                    setState(() {
                      _selectedDocteurId =
                          value;
                    });
                  },
                ),

              const SizedBox(height: 16),

              // -------------------------
              // LIEU
              // -------------------------
              TextFormField(
                controller: _lieuController,

                decoration:
                    InputDecoration(
                  labelText: t.location,
                  border:
                      const OutlineInputBorder(),
                  prefixIcon: const Icon(
                    Icons.location_on,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // -------------------------
              // DESCRIPTION
              // -------------------------
              TextFormField(
                controller:
                    _descriptionController,

                maxLines: 4,

                decoration:
                    InputDecoration(
                  labelText:
                      t.description,
                  border:
                      const OutlineInputBorder(),
                  prefixIcon: const Icon(
                    Icons.description,
                  ),
                  alignLabelWithHint: true,
                ),
              ),

              // -------------------------
              // FAVORI
              // -------------------------
              SwitchListTile(
                contentPadding:
                    EdgeInsets.zero,

                title: Text(
                  t.addToFavorites,
                ),

                subtitle: Text(
                  t.favoriteDescription,
                ),

                secondary: Icon(
                  _estFavori
                      ? Icons.star
                      : Icons.star_border,
                ),

                value: _estFavori,

                onChanged: (value) {
                  setState(() {
                    _estFavori = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              // -------------------------
              // ENREGISTRER
              // -------------------------
              SizedBox(
                height: 50,

                child: ElevatedButton.icon(
                  onPressed:
                      _viewModel.isSaving
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
                      : const Icon(
                          Icons.save,
                        ),

                  label: Text(
                    _viewModel.isSaving
                        ? t.saving
                        : _isEditing
                            ? t.edit
                            : t.save,
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
