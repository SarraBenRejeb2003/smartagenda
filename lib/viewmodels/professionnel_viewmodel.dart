import 'package:flutter/foundation.dart';

import '../models/professionnel.dart';
import '../repositories/professionnel_repository.dart';

class ProfessionnelViewModel extends ChangeNotifier {
  final ProfessionnelRepository _repository;

  ProfessionnelViewModel({
    ProfessionnelRepository? repository,
  }) : _repository =
            repository ?? ProfessionnelRepository();

  List<Professionnel> _professionnels = [];

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<Professionnel> get professionnels =>
      List.unmodifiable(_professionnels);

  bool get isLoading => _isLoading;

  bool get isSaving => _isSaving;

  String? get errorMessage => _errorMessage;

  Future<void> loadProfessionnels() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _professionnels = await _repository.getProfessionnels();
    } catch (e) {
      _errorMessage =
          'Erreur lors du chargement des professionnels.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> ajouterProfessionnel(
    Professionnel professionnel,
  ) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.insertProfessionnel(professionnel);
      await loadProfessionnels();
      return true;
    } catch (e) {
      _errorMessage =
          'Erreur lors de l\'ajout du professionnel.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> modifierProfessionnel(
    Professionnel professionnel,
  ) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateProfessionnel(professionnel);
      await loadProfessionnels();
      return true;
    } catch (e) {
      _errorMessage =
          'Erreur lors de la modification du professionnel.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> supprimerProfessionnel(int id) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteProfessionnel(id);
      await loadProfessionnels();
      return true;
    } catch (e) {
      _errorMessage =
          'Erreur lors de la suppression du professionnel.';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}