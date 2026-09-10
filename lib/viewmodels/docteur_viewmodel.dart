import 'package:flutter/foundation.dart';

import '../models/docteur.dart';
import '../repositories/docteur_repository.dart';

class DocteurViewModel extends ChangeNotifier {
  final DocteurRepository _repository;

  DocteurViewModel({
    DocteurRepository? repository,
  }) : _repository = repository ?? DocteurRepository();

  List<Docteur> _docteurs = [];

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<Docteur> get docteurs => List.unmodifiable(_docteurs);
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<void> loadDocteurs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _docteurs = await _repository.getDocteurs();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des docteurs.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> ajouterDocteur(Docteur docteur) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.insertDocteur(docteur);
      await loadDocteurs();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'ajout du docteur.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> modifierDocteur(Docteur docteur) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateDocteur(docteur);
      await loadDocteurs();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la modification du docteur.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> supprimerDocteur(int id) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteDocteur(id);
      await loadDocteurs();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression du docteur.';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}