import '../database/database_helper.dart';
import '../models/docteur.dart';

class DocteurRepository {
  final DatabaseHelper _databaseHelper;

  DocteurRepository({
    DatabaseHelper? databaseHelper,
  }) : _databaseHelper =
            databaseHelper ?? DatabaseHelper.instance;

  Future<List<Docteur>> getDocteurs() {
    return _databaseHelper.getDocteurs();
  }

  Future<int> insertDocteur(Docteur docteur) {
    return _databaseHelper.insertDocteur(docteur);
  }

  Future<int> updateDocteur(Docteur docteur) {
    return _databaseHelper.updateDocteur(docteur);
  }

  Future<int> deleteDocteur(int id) {
    return _databaseHelper.deleteDocteur(id);
  }
}