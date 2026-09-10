import '../database/database_helper.dart';
import '../models/professionnel.dart';

class ProfessionnelRepository {
  final DatabaseHelper _databaseHelper;

  ProfessionnelRepository({
    DatabaseHelper? databaseHelper,
  }) : _databaseHelper =
            databaseHelper ?? DatabaseHelper.instance;

  Future<List<Professionnel>> getProfessionnels() {
    return _databaseHelper.getProfessionnels();
  }

  Future<int> insertProfessionnel(
    Professionnel professionnel,
  ) {
    return _databaseHelper.insertProfessionnel(professionnel);
  }

  Future<int> updateProfessionnel(
    Professionnel professionnel,
  ) {
    return _databaseHelper.updateProfessionnel(professionnel);
  }

  Future<int> deleteProfessionnel(int id) {
    return _databaseHelper.deleteProfessionnel(id);
  }
}