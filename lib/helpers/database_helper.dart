import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'wim_db.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Création de la table Utilisateur
    await db.execute('''
      CREATE TABLE Utilisateur (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pseudo TEXT NOT NULL,
        pin TEXT NOT NULL
      )
    ''');

    // Création de la table Mariage
    await db.execute('''
      CREATE TABLE Mariage (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        nomMarie1 TEXT NOT NULL,
        nomMarie2 TEXT NOT NULL,
        date TEXT NOT NULL,
        lieu TEXT NOT NULL,
        heure TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES Utilisateur (id) ON DELETE CASCADE
      )
    ''');

    // Création de la table Invité
    await db.execute('''
      CREATE TABLE Invite (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mariageId INTEGER NOT NULL,
        nom TEXT NOT NULL,
        prenom TEXT NOT NULL,
        qrCode TEXT UNIQUE NOT NULL,
        presence TEXT DEFAULT 'absent',
        FOREIGN KEY (mariageId) REFERENCES Mariage (id) ON DELETE CASCADE
      )
    ''');
  }

  // Fermeture de la base de données
  Future<void> close() async {
    final db = await database;
    db.close();
  }

  // Ajouter un utilisateur
  Future<int> insertUtilisateur(Map<String, dynamic> utilisateur) async {
    final db = await database;
    return await db.insert('Utilisateur', utilisateur);
  }

  // Obtenir tous les utilisateurs
  Future<List<Map<String, dynamic>>> getUtilisateurs() async {
    final db = await database;
    return await db.query('Utilisateur');
  }

  // Supprimer un utilisateur
  Future<int> deleteUtilisateur(int id) async {
    final db = await database;
    return await db.delete('Utilisateur', where: 'id = ?', whereArgs: [id]);
  }

  // Ajouter un mariage
  Future<int> insertMariage(Map<String, dynamic> mariage) async {
    final db = await database;
    return await db.insert('Mariage', mariage);
  }

  // Obtenir tous les mariages pour un utilisateur
  Future<List<Map<String, dynamic>>> getMariages() async {
    final db = await database;
    return await db.query('Mariage', orderBy: 'nomMarie1 ASC');
  }

  // Supprimer un mariage
  Future<int> deleteMariage(int id) async {
    final db = await database;
    return await db.delete('Mariage', where: 'id = ?', whereArgs: [id]);
  }

  // Ajouter un invité
  Future<int> insertInvite(Map<String, dynamic> invite) async {
    final db = await database;
    return await db.insert('Invite', invite);
  }

 // Obtenir tous les invités pour un mariage
  Future<List<Map<String, dynamic>>> getInvites(int mariageId) async {
    final db = await database;
    return await db.query('Invite', where: 'mariageId = ?', whereArgs: [mariageId]);
  }

 // Mettre à jour la présence d'un invité
  Future<int> updatePresence(int id, String presence) async {
    final db = await database;
    return await db.update(
      'Invite',
      {'presence': presence},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

 // Supprimer un invité
  Future<int> deleteInvite(int id) async {
    final db = await database;
    return await db.delete('Invite', where: 'id = ?', whereArgs: [id]);
  }

  /// Récupérer un invité en fonction de son QR code
  Future<Map<String, dynamic>?> getInviteByQRCode(String qrCode) async {
    final db = await database;
    final result = await db.query(
      'Invite',
      where: 'qrCode = ?',
      whereArgs: [qrCode],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  /// Mettre à jour les informations d'un invité
  Future<int> updateInvite(int id, Map<String, dynamic> updatedInvite) async {
    final db = await database;
    return await db.update(
      'Invite',
      updatedInvite,
      where: 'id = ?',
      whereArgs: [id],
    );
  }



}
