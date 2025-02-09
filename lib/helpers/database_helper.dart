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
      version: 4, // Changement de version pour appliquer les mises à jour
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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

    // Création de la table Invité mise à jour
    await db.execute('''
      CREATE TABLE Invite (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mariageId INTEGER NOT NULL,
        nomPorteur TEXT NOT NULL,
        ville TEXT NOT NULL,
        nom TEXT NOT NULL,
        telephone TEXT NOT NULL,
        nombrePlaces INTEGER NOT NULL,
        nombrePresent INTEGER DEFAULT 0,
        qrCode TEXT NOT NULL,
        presence TEXT DEFAULT 'absent',
        heureArrivee TEXT,
        FOREIGN KEY (mariageId) REFERENCES Mariage (id) ON DELETE CASCADE
      )
    ''');

    // Insertion d'un utilisateur par défaut
    await db.insert('Utilisateur', {
      'pseudo': 'admin',
      'pin': '1234',
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      // Supprime l'ancienne table Invité si elle existe
      await db.execute('DROP TABLE IF EXISTS Invite');
      await db.execute("DROP TABLE IF EXISTS Utilisateur");
      await db.execute("DROP TABLE IF EXISTS Mariage");
      // Recrée la table avec les nouvelles colonnes
      await _onCreate(db, newVersion);
    }
  }

  // Reinitialiser la base de données
  Future<void> refrsh_db() async {
    final db = await database;
    db.execute("DELETE FROM Invite");
  }

  // Fermer la base de données
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

  // Obtenir tous les mariages
  Future<List<Map<String, dynamic>>> getMariages() async {
    final db = await database;
    return await db.query('Mariage', orderBy: 'nomMarie1 ASC');
  }

  // Supprimer un mariage
  Future<int> deleteMariage(int id) async {
    final db = await database;
    // supprimer tous les invités liés au mariage
     var invitees = await getInvites(id);

     if(invitees.isEmpty) return 0;

     for(var invite in invitees){
       await deleteInvite(invite['id']);
     }

    return await db.delete('Mariage', where: 'id = ?', whereArgs: [id]);
  }

  // Ajouter un invité avec les nouveaux champs
  Future<int> insertInvite(Map<String, dynamic> invite) async {
    final db = await database;
    return await db.insert('Invite', invite);
  }

  // Obtenir tous les invités pour un mariage
  Future<List<Map<String, dynamic>>> getInvites(int mariageId) async {
    final db = await database;
    return await db.query('Invite', where: 'mariageId = ?', whereArgs: [mariageId]);
  }

  // Mettre à jour la présence d'un invité en fonction du nombre de présents
  Future<int> updatePresence(int id, int nombrePresent) async {
    final db = await database;

    // Récupérer l'invité concerné
    final invite = await db.query('Invite', where: 'id = ?', whereArgs: [id]);

    if (invite.isEmpty) return 0;

    int nombrePlaces = invite.first['nombrePlaces'] as int;
    String presence;

    if (nombrePresent == 0) {
      presence = 'absent';
    } else if (nombrePresent < nombrePlaces) {
      presence = 'partiel';
    } else {
      presence = 'complet';
    }

    return await db.update(
      'Invite',
      {
        'nombrePresent': nombrePresent,
        'presence': presence,
        'heureArrivee': nombrePresent > 0 ? DateTime.now().toIso8601String() : null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Supprimer un invité
  Future<int> deleteInvite(int id) async {
    final db = await database;
    return await db.delete('Invite', where: 'id = ?', whereArgs: [id]);
  }

  // Récupérer un invité via son QR Code
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

  // Mettre à jour les informations d'un invité
  Future<int> updateInvite(int id, Map<String, dynamic> updatedInvite) async {
    final db = await database;
    return await db.update(
      'Invite',
      updatedInvite,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // reccupérer le nombre total d'invités par mariage
  Future<int> getInviteCount(int mariageId) async {
    final db = await database;

    var listeinvites = await getInvites(mariageId);

    int nbre = 0;

    for (var invite in listeinvites) {
      int invitNombrePlaces = invite["nombrePlaces"];
      nbre += invitNombrePlaces;
    }

    return nbre;
  }

  // reccupérer le nombre total d'invités présent par mariage
  Future<int> getPresentInvite(int mariageId) async {
    final db = await database;

    var listeinvites = await getInvites(mariageId);

    int nbre = 0;

    for (var invite in listeinvites) {
      int invitNombrePresents = invite["nombrePresent"];
      nbre += invitNombrePresents;
    }

    return nbre;
  }

  // Ajouter une présence sur le billet de l'invité
  Future<void> addPresence(int inviteid)async {
    final db = database;
    db.then((value) => value.rawUpdate("UPDATE Invite SET nombrePresent = nombrePresent + 1 WHERE id = ?", [inviteid]));
  }
}
