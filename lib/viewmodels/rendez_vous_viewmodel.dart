import 'package:flutter/foundation.dart';

import '../models/rendez_vous.dart';
import '../models/professionnel.dart';
import '../models/docteur.dart';
import '../repositories/rendez_vous_repository.dart';

class RendezVousViewModel extends ChangeNotifier {
  final RendezVousRepository _repository;

  RendezVousViewModel({
    RendezVousRepository? repository,
  }) : _repository =
            repository ?? RendezVousRepository();

  List<RendezVous> _rendezVous = [];
  List<Professionnel> _professionnels = [];
  List<Docteur> _docteurs = [];

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  // ============================================================
  // GETTERS
  // ============================================================

  List<RendezVous> get rendezVous =>
      List.unmodifiable(_rendezVous);

  List<Professionnel> get professionnels =>
      List.unmodifiable(_professionnels);

  List<Docteur> get docteurs =>
      List.unmodifiable(_docteurs);

  bool get isLoading => _isLoading;

  bool get isSaving => _isSaving;

  String? get errorMessage => _errorMessage;

  // ============================================================
  // CHARGEMENT
  // ============================================================

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _rendezVous = await _repository.getRendezVous();

      _professionnels =
          await _repository.getProfessionnels();

      _docteurs =
          await _repository.getDocteurs();
    } catch (e) {
      _errorMessage =
          'Erreur lors du chargement des données.';
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // AJOUTER RENDEZ-VOUS
  // ============================================================

  Future<bool> ajouterRendezVous(
    RendezVous rendezVous,
  ) async {
    _isSaving = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final overlap =
          await _repository.hasRendezVousOverlap(
        dateRDV: rendezVous.dateRDV,
        heureDebut: rendezVous.heureDebut,
        heureFin: rendezVous.heureFin,
      );

      if (overlap) {
        _errorMessage =
            'Ce rendez-vous chevauche un autre rendez-vous.';

        return false;
      }

      await _repository.insertRendezVous(
        rendezVous,
      );

      await loadData();

      return true;
    } catch (e) {
      _errorMessage =
          'Erreur lors de l\'ajout du rendez-vous.';

      return false;
    } finally {
      _isSaving = false;

      notifyListeners();
    }
  }

  // ============================================================
  // MODIFIER RENDEZ-VOUS
  // ============================================================

  Future<bool> modifierRendezVous(
    RendezVous rendezVous,
  ) async {
    _isSaving = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final overlap =
          await _repository.hasRendezVousOverlap(
        dateRDV: rendezVous.dateRDV,
        heureDebut: rendezVous.heureDebut,
        heureFin: rendezVous.heureFin,
        excludeId: rendezVous.idRendezVous,
      );

      if (overlap) {
        _errorMessage =
            'Ce rendez-vous chevauche un autre rendez-vous.';

        return false;
      }

      await _repository.updateRendezVous(
        rendezVous,
      );

      await loadData();

      return true;
    } catch (e) {
      _errorMessage =
          'Erreur lors de la modification du rendez-vous.';

      return false;
    } finally {
      _isSaving = false;

      notifyListeners();
    }
  }

  // ============================================================
  // SUPPRIMER RENDEZ-VOUS
  // ============================================================

  Future<bool> supprimerRendezVous(
    int id,
  ) async {
    _errorMessage = null;

    notifyListeners();

    try {
      await _repository.deleteRendezVous(id);

      await loadData();

      return true;
    } catch (e) {
      _errorMessage =
          'Erreur lors de la suppression du rendez-vous.';

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // RECHERCHER UN PROFESSIONNEL
  // ============================================================

  Professionnel? getProfessionnel(int? id) {
    if (id == null) return null;

    try {
      return _professionnels.firstWhere(
        (professionnel) =>
            professionnel.idProfessionnel == id,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // RECHERCHER UN DOCTEUR
  // ============================================================

  Docteur? getDocteur(int? id) {
    if (id == null) return null;

    try {
      return _docteurs.firstWhere(
        (docteur) =>
            docteur.idDocteur == id,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // NOM DU CONTACT
  // ============================================================

  String getContactName(
    RendezVous rendezVous,
  ) {
    if (rendezVous.typeRDV == 'Professionnel') {
      final professionnel =
          getProfessionnel(
        rendezVous.idProfessionnel,
      );

      if (professionnel == null) {
        return 'Non renseigné';
      }

      return professionnel.nom;
    }

    if (rendezVous.typeRDV == 'Medical') {
      final docteur =
          getDocteur(
        rendezVous.idDocteur,
      );

      if (docteur == null) {
        return 'Non renseigné';
      }

      return docteur.nom;
    }

    return 'Privé';
  }

  // ============================================================
  // EFFACER ERREUR
  // ============================================================

  void clearError() {
    _errorMessage = null;

    notifyListeners();
  }
  Future<bool> modifierFavori(
  int id,
  bool estFavori,
) async {
  try {
    await _repository.updateFavoriRendezVous(
      id,
      estFavori,
    );

    await loadData();
    return true;
  } catch (e) {
    _errorMessage =
        'Erreur lors de la modification du favori.';
    notifyListeners();
    return false;
  }
}

Future<bool> modifierStatut(
  int id,
  String statut,
) async {
  try {
    await _repository.updateStatutRendezVous(
      id,
      statut,
    );

    await loadData();
    return true;
  } catch (e) {
    _errorMessage =
        'Erreur lors de la modification du statut.';
    notifyListeners();
    return false;
  }
}
}