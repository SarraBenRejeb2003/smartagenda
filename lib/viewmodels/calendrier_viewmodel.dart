import 'package:flutter/foundation.dart';

import '../models/rendez_vous.dart';
import '../models/professionnel.dart';
import '../models/docteur.dart';
import '../repositories/rendez_vous_repository.dart';
import '../services/notification_service.dart';

class CalendrierViewModel extends ChangeNotifier {
  final RendezVousRepository _repository;
  final NotificationService _notificationService;

  CalendrierViewModel({
    RendezVousRepository? repository,
    NotificationService? notificationService,
  })  : _repository = repository ?? RendezVousRepository(),
        _notificationService =
            notificationService ?? NotificationService.instance;

  List<RendezVous> _rendezVous = [];
  List<Professionnel> _professionnels = [];
  List<Docteur> _docteurs = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<RendezVous> get rendezVous =>
      List.unmodifiable(_rendezVous);

  List<Professionnel> get professionnels =>
      List.unmodifiable(_professionnels);

  List<Docteur> get docteurs =>
      List.unmodifiable(_docteurs);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _rendezVous = await _repository.getRendezVous();
      _professionnels = await _repository.getProfessionnels();
      _docteurs = await _repository.getDocteurs();
    } catch (e) {
      _errorMessage =
          'Erreur lors du chargement des données.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> supprimerRendezVous(int id) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteRendezVous(id);

      // Annuler la notification associée au rendez-vous.
      await _notificationService.cancelNotification(id);

      await loadData();
      return true;
    } catch (e) {
      _errorMessage =
          'Erreur lors de la suppression du rendez-vous.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> modifierFavori(
    int id,
    bool estFavori,
  ) async {
    _errorMessage = null;

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
    _errorMessage = null;

    try {
      await _repository.updateStatutRendezVous(
        id,
        statut,
      );

      // Si le rendez-vous est annulé ou terminé,
      // son rappel ne doit plus être envoyé.
      if (statut == 'Annule' || statut == 'Termine') {
        await _notificationService.cancelNotification(id);
      }

      await loadData();

      return true;
    } catch (e) {
      _errorMessage =
          'Erreur lors de la modification du statut.';
      notifyListeners();

      return false;
    }
  }

  Professionnel? getProfessionnel(int? id) {
    if (id == null) {
      return null;
    }

    try {
      return _professionnels.firstWhere(
        (professionnel) =>
            professionnel.idProfessionnel == id,
      );
    } catch (_) {
      return null;
    }
  }

  Docteur? getDocteur(int? id) {
    if (id == null) {
      return null;
    }

    try {
      return _docteurs.firstWhere(
        (docteur) => docteur.idDocteur == id,
      );
    } catch (_) {
      return null;
    }
  }

  String getContactName(RendezVous rendezVous) {
    if (rendezVous.typeRDV == 'Professionnel') {
      final professionnel =
          getProfessionnel(rendezVous.idProfessionnel);

      if (professionnel == null) {
        return '';
      }

      final details = <String>[];

      if (professionnel.societe.trim().isNotEmpty) {
        details.add(professionnel.societe.trim());
      }

      if (professionnel.fonction.trim().isNotEmpty) {
        details.add(professionnel.fonction.trim());
      }

      if (details.isEmpty) {
        return professionnel.nom;
      }

      return '${professionnel.nom} - ${details.join(' - ')}';
    }

    if (rendezVous.typeRDV == 'Medical') {
      final docteur =
          getDocteur(rendezVous.idDocteur);

      if (docteur == null) {
        return '';
      }

      if (docteur.specialite != null &&
          docteur.specialite!.trim().isNotEmpty) {
        return '${docteur.nom} - ${docteur.specialite!.trim()}';
      }

      return docteur.nom;
    }

    return 'Privé';
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}