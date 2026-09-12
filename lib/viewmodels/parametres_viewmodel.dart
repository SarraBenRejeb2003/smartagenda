import 'package:flutter/foundation.dart';

import '../models/parametres.dart';
import '../repositories/parametres_repository.dart';

class ParametresViewModel extends ChangeNotifier {
  final ParametresRepository _repository;

  Parametres? _parametres;

  bool _isLoading = false;
  String? _errorMessage;

  ParametresViewModel({
    ParametresRepository? repository,
  }) : _repository =
          repository ?? ParametresRepository();

  Parametres? get parametres => _parametres;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<void> loadParametres() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _parametres = await _repository.getParametres();
    } catch (e) {
      _errorMessage =
          'Erreur lors du chargement des paramètres.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> modifierParametres(
    Parametres nouveauxParametres,
  ) async {
    _errorMessage = null;

    try {
      await _repository.updateParametres(
        nouveauxParametres,
      );

      _parametres = nouveauxParametres;

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage =
          'Erreur lors de la modification des paramètres.';
      notifyListeners();

      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}