import '../database/database_helper.dart';
import '../models/rendez_vous.dart';
import '../models/professionnel.dart';
import '../models/docteur.dart';

class RendezVousRepository {
  final DatabaseHelper _databaseHelper;

  RendezVousRepository({
    DatabaseHelper? databaseHelper,
  }) : _databaseHelper =
            databaseHelper ?? DatabaseHelper.instance;

  // ============================================================
  // RENDEZ-VOUS
  // ============================================================

  Future<List<RendezVous>> getRendezVous() {
    return _databaseHelper.getRendezVous();
  }

  Future<int> insertRendezVous(
    RendezVous rendezVous,
  ) {
    return _databaseHelper.insertRendezVous(rendezVous);
  }

  Future<int> updateRendezVous(
    RendezVous rendezVous,
  ) {
    return _databaseHelper.updateRendezVous(rendezVous);
  }

  Future<int> deleteRendezVous(int id) {
    return _databaseHelper.deleteRendezVous(id);
  }

  Future<bool> hasRendezVousOverlap({
    required String dateRDV,
    required String heureDebut,
    required String heureFin,
    int? excludeId,
  }) {
    return _databaseHelper.hasRendezVousOverlap(
      dateRDV: dateRDV,
      heureDebut: heureDebut,
      heureFin: heureFin,
      excludeId: excludeId,
    );
  }

  // ============================================================
  // PROFESSIONNELS
  // ============================================================

  Future<List<Professionnel>> getProfessionnels() {
    return _databaseHelper.getProfessionnels();
  }

  // ============================================================
  // DOCTEURS
  // ============================================================

  Future<List<Docteur>> getDocteurs() {
    return _databaseHelper.getDocteurs();
  }
}