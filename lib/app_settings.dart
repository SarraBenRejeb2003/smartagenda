import 'package:flutter/material.dart';

import 'models/parametres.dart';
import 'repositories/parametres_repository.dart';

class AppSettings extends ChangeNotifier {
  final ParametresRepository _repository;

  Parametres _parametres = Parametres();

  AppSettings({
    ParametresRepository? repository,
  }) : _repository = repository ?? ParametresRepository();

  Parametres get parametres => _parametres;

  Color get themeColor => _couleurDepuisHex(
        _parametres.themeCouleur,
      );

  Future<void> load() async {
    _parametres = await _repository.getParametres();
    notifyListeners();
  }

  Future<void> update(Parametres nouveauxParametres) async {
    await _repository.updateParametres(
      nouveauxParametres,
    );

    _parametres = nouveauxParametres;
    notifyListeners();
  }

  Color _couleurDepuisHex(String hex) {
    final valeur = hex.replaceFirst('#', '');

    return Color(
      int.parse('FF$valeur', radix: 16),
    );
  }
}