import 'package:flutter/material.dart';

import '../../models/docteur.dart';
import '../../viewmodels/docteur_viewmodel.dart';

class DocteurEditPage extends StatefulWidget {
  final Map<String, String>? docteur;

  const DocteurEditPage({
    super.key,
    this.docteur,
  });

  @override
  State<DocteurEditPage> createState() {
    return _DocteurEditPageState();
  }
}

class _DocteurEditPageState extends State<DocteurEditPage> {
  late final DocteurViewModel _viewModel;

  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController();
  final _specialiteController = TextEditingController();
  final _adresseController = TextEditingController();
  final _telephoneController = TextEditingController();

  bool get isEditing => widget.docteur != null;

  @override
  void initState() {
    super.initState();

    _viewModel = DocteurViewModel();

    if (widget.docteur != null) {
      _nomController.text = widget.docteur!['nom'] ?? '';
      _specialiteController.text =
          widget.docteur!['specialite'] ?? '';
      _adresseController.text =
          widget.docteur!['adresseCabinet'] ?? '';
      _telephoneController.text =
          widget.docteur!['telephone'] ?? '';
    }

    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (!mounted) return;

    setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();

    _nomController.dispose();
    _specialiteController.dispose();
    _adresseController.dispose();
    _telephoneController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF159E9E),

      appBar: AppBar(
        backgroundColor: const Color(0xFF159E9E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isEditing ? 'Modifier Docteur' : 'Docteur',
          style: const TextStyle(fontSize: 25),
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Nom *'),

                _buildTextField(
                  controller: _nomController,
                  hint: 'Nom du docteur',
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Le nom est obligatoire';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                _buildLabel('Spécialité'),

                _buildTextField(
                  controller: _specialiteController,
                  hint: 'Spécialité',
                ),

                const SizedBox(height: 15),

                _buildLabel('Adresse cabinet'),

                _buildTextField(
                  controller: _adresseController,
                  hint: 'Adresse du cabinet',
                ),

                const SizedBox(height: 15),

                _buildLabel('Téléphone'),

                _buildTextField(
                  controller: _telephoneController,
                  hint: 'Téléphone',
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed:
                        _viewModel.isSaving
                            ? null
                            : _enregistrer,
                    icon: _viewModel.isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check),
                    label: Text(
                      _viewModel.isSaving
                          ? 'Enregistrement...'
                          : 'Enregistrer',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _viewModel.isSaving
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                    icon: const Icon(Icons.close),
                    label: const Text(
                      'Annuler',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 21,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final docteur = Docteur(
      idDocteur: _getExistingId(),
      nom: _nomController.text.trim(),
      specialite: _specialiteController.text.trim(),
      adresseCabinet: _adresseController.text.trim(),
      telephone: _telephoneController.text.trim(),
    );

    final bool success;

    if (isEditing) {
      success = await _viewModel.modifierDocteur(docteur);
    } else {
      success = await _viewModel.ajouterDocteur(docteur);
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

    final result = <String, String>{
      'idDocteur': _getExistingId()?.toString() ?? '',
      'nom': _nomController.text.trim(),
      'specialite': _specialiteController.text.trim(),
      'adresseCabinet':
          _adresseController.text.trim(),
      'telephone': _telephoneController.text.trim(),
    };

    Navigator.pop(context, result);
  }

  int? _getExistingId() {
    if (!isEditing) {
      return null;
    }

    final id = widget.docteur!['idDocteur'];

    if (id == null || id.isEmpty) {
      return null;
    }

    return int.tryParse(id);
  }
}