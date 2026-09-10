import 'package:flutter/material.dart';

import '../../models/professionnel.dart';
import '../../viewmodels/professionnel_viewmodel.dart';

class ProfessionnelEditPage extends StatefulWidget {
  final Map<String, String>? professionnel;

  const ProfessionnelEditPage({super.key, this.professionnel});

  @override
  State<ProfessionnelEditPage> createState() => _ProfessionnelEditPageState();
}

class _ProfessionnelEditPageState extends State<ProfessionnelEditPage> {
  late final ProfessionnelViewModel _viewModel;

  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController();
  final _societeController = TextEditingController();
  final _professionController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool get isEditing => widget.professionnel != null;

  @override
  void initState() {
    super.initState();

    _viewModel = ProfessionnelViewModel();

    if (widget.professionnel != null) {
      _nomController.text = widget.professionnel!['nom'] ?? '';

      _societeController.text = widget.professionnel!['societe'] ?? '';

      _professionController.text = widget.professionnel!['profession'] ?? '';

      _telephoneController.text = widget.professionnel!['telephone'] ?? '';

      _emailController.text = widget.professionnel!['email'] ?? '';
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
    _societeController.dispose();
    _professionController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();

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
          isEditing ? 'Modifier Professionnel' : 'Professionnel',
          style: const TextStyle(fontSize: 25),
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,

          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Nom *'),

                _buildTextField(
                  controller: _nomController,
                  hint: 'Nom du professionnel',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le nom est obligatoire';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                _buildLabel('Société'),

                _buildTextField(
                  controller: _societeController,
                  hint: 'Société',
                ),

                const SizedBox(height: 15),

                _buildLabel('Profession'),

                _buildTextField(
                  controller: _professionController,
                  hint: 'Profession',
                ),

                const SizedBox(height: 15),

                _buildLabel('Téléphone'),

                _buildTextField(
                  controller: _telephoneController,
                  hint: 'Téléphone',
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 15),

                _buildLabel('Email'),

                _buildTextField(
                  controller: _emailController,
                  hint: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _viewModel.isSaving ? null : _enregistrer,
                    icon: _viewModel.isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: Text(
                      _viewModel.isSaving ? 'Enregistrement...' : 'Enregistrer',
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

    final professionnel = Professionnel(
  idProfessionnel: _getExistingId(),
  nom: _nomController.text.trim(),
  societe: _societeController.text.trim(),
  fonction: _professionController.text.trim(),
  telephone: _telephoneController.text.trim(),
  email: _emailController.text.trim(),
);

    final bool success;

    if (isEditing) {
      success = await _viewModel.modifierProfessionnel(professionnel);
    } else {
      success = await _viewModel.ajouterProfessionnel(professionnel);
    }

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage ?? 'Une erreur est survenue.'),
        ),
      );
      return;
    }

    final result = <String, String>{
      'idProfessionnel': _getExistingId()?.toString() ?? '',
      'nom': _nomController.text.trim(),
      'societe': _societeController.text.trim(),
      'profession': _professionController.text.trim(),
      'telephone': _telephoneController.text.trim(),
      'email': _emailController.text.trim(),
    };

    Navigator.pop(context, result);
  }

  int? _getExistingId() {
    if (!isEditing) {
      return null;
    }

    final id = widget.professionnel!['idProfessionnel'];

    if (id == null || id.isEmpty) {
      return null;
    }

    return int.tryParse(id);
  }

  
}
