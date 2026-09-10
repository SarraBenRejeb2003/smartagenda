import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/professionnel.dart';
import '../models/docteur.dart';
import '../models/rendez_vous.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('smart_agenda.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Professionnel (
        idProfessionnel INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        societe TEXT,
        fonction TEXT,
        telephone TEXT,
        email TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE Docteur (
        idDocteur INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        specialite TEXT,
        telephone TEXT,
        adresseCabinet TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE RendezVous (
        idRendezVous INTEGER PRIMARY KEY AUTOINCREMENT,
        dateRDV TEXT NOT NULL,
        heureDebut TEXT NOT NULL,
        heureFin TEXT NOT NULL,
        typeRDV TEXT NOT NULL,
        titre TEXT NOT NULL,
        description TEXT,
        lieu TEXT,
        idProfessionnel INTEGER,
        idDocteur INTEGER,
        statut TEXT NOT NULL DEFAULT 'Planifie',
        estFavori INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE RendezVous
        ADD COLUMN statut TEXT NOT NULL DEFAULT 'Planifie'
      ''');

      await db.execute('''
        ALTER TABLE RendezVous
        ADD COLUMN estFavori INTEGER NOT NULL DEFAULT 0
      ''');
    }
  }

  // ─────────────────────────────────────────────
  // PROFESSIONNELS
  // ─────────────────────────────────────────────

  Future<int> insertProfessionnel(
    Professionnel professionnel,
  ) async {
    final db = await database;

    return await db.insert(
      'Professionnel',
      professionnel.toMap(),
    );
  }

  Future<List<Professionnel>> getProfessionnels() async {
    final db = await database;

    final result = await db.query(
      'Professionnel',
      orderBy: 'nom ASC',
    );

    return result
        .map((map) => Professionnel.fromMap(map))
        .toList();
  }

  Future<int> updateProfessionnel(
    Professionnel professionnel,
  ) async {
    final db = await database;

    return await db.update(
      'Professionnel',
      professionnel.toMap(),
      where: 'idProfessionnel = ?',
      whereArgs: [professionnel.idProfessionnel],
    );
  }

  Future<int> deleteProfessionnel(int id) async {
    final db = await database;

    return await db.delete(
      'Professionnel',
      where: 'idProfessionnel = ?',
      whereArgs: [id],
    );
  }

  // ─────────────────────────────────────────────
  // DOCTEURS
  // ─────────────────────────────────────────────

  Future<int> insertDocteur(Docteur docteur) async {
    final db = await database;

    return await db.insert(
      'Docteur',
      docteur.toMap(),
    );
  }

  Future<List<Docteur>> getDocteurs() async {
    final db = await database;

    final result = await db.query(
      'Docteur',
      orderBy: 'nom ASC',
    );

    return result
        .map((map) => Docteur.fromMap(map))
        .toList();
  }

  Future<int> updateDocteur(Docteur docteur) async {
    final db = await database;

    return await db.update(
      'Docteur',
      docteur.toMap(),
      where: 'idDocteur = ?',
      whereArgs: [docteur.idDocteur],
    );
  }

  Future<int> deleteDocteur(int id) async {
    final db = await database;

    return await db.delete(
      'Docteur',
      where: 'idDocteur = ?',
      whereArgs: [id],
    );
  }

  // ─────────────────────────────────────────────
  // RENDEZ-VOUS
  // ─────────────────────────────────────────────

  Future<int> insertRendezVous(
    RendezVous rendezVous,
  ) async {
    final db = await database;

    final data = rendezVous.toMap();

    data.remove('idRendezVous');

    return await db.insert(
      'RendezVous',
      data,
    );
  }

  Future<List<RendezVous>> getRendezVous() async {
    final db = await database;

    final result = await db.query(
      'RendezVous',
      orderBy: 'dateRDV ASC, heureDebut ASC',
    );

    return result
        .map((map) => RendezVous.fromMap(map))
        .toList();
  }

  Future<int> updateRendezVous(
    RendezVous rendezVous,
  ) async {
    final db = await database;

    final data = rendezVous.toMap();

    data.remove('idRendezVous');

    return await db.update(
      'RendezVous',
      data,
      where: 'idRendezVous = ?',
      whereArgs: [rendezVous.idRendezVous],
    );
  }

  Future<int> deleteRendezVous(int id) async {
    final db = await database;

    return await db.delete(
      'RendezVous',
      where: 'idRendezVous = ?',
      whereArgs: [id],
    );
  }

  // ─────────────────────────────────────────────
  // FAVORI
  // ─────────────────────────────────────────────

  Future<int> updateFavoriRendezVous(
    int id,
    bool estFavori,
  ) async {
    final db = await database;

    return await db.update(
      'RendezVous',
      {
        'estFavori': estFavori ? 1 : 0,
      },
      where: 'idRendezVous = ?',
      whereArgs: [id],
    );
  }

  // ─────────────────────────────────────────────
  // STATUT
  // ─────────────────────────────────────────────

  Future<int> updateStatutRendezVous(
    int id,
    String statut,
  ) async {
    final db = await database;

    return await db.update(
      'RendezVous',
      {
        'statut': statut,
      },
      where: 'idRendezVous = ?',
      whereArgs: [id],
    );
  }

  // ─────────────────────────────────────────────
  // CHEVAUCHEMENT
  // ─────────────────────────────────────────────

  Future<bool> hasRendezVousOverlap({
    required String dateRDV,
    required String heureDebut,
    required String heureFin,
    int? excludeId,
  }) async {
    final db = await database;

    String where =
        'dateRDV = ? AND heureDebut < ? AND heureFin > ?';

    final whereArgs = <dynamic>[
      dateRDV,
      heureFin,
      heureDebut,
    ];

    if (excludeId != null) {
      where += ' AND idRendezVous != ?';
      whereArgs.add(excludeId);
    }

    final result = await db.query(
      'RendezVous',
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );

    return result.isNotEmpty;
  }
}