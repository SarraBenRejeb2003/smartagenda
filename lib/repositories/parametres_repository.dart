import '../database/database_helper.dart';
import '../models/parametres.dart';

class ParametresRepository {
  final DatabaseHelper _databaseHelper;

  ParametresRepository({
    DatabaseHelper? databaseHelper,
  }) : _databaseHelper =
          databaseHelper ?? DatabaseHelper.instance;

  Future<Parametres> getParametres() {
    return _databaseHelper.getParametres();
  }

  Future<int> updateParametres(
    Parametres parametres,
  ) {
    return _databaseHelper.updateParametres(
      parametres,
    );
  }
}