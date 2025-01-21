import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/mariage_model.dart';

class CreateMariageScreen extends StatefulWidget {
  final int userId; // ID de l'utilisateur connecté

  CreateMariageScreen({required this.userId});

  @override
  _CreateMariageScreenState createState() => _CreateMariageScreenState();
}

class _CreateMariageScreenState extends State<CreateMariageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mariage1Controller = TextEditingController();
  final _mariage2Controller = TextEditingController();
  final _dateController = TextEditingController();
  final _lieuController = TextEditingController();
  final _heureController = TextEditingController();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void dispose() {
    // Libérer les contrôleurs pour éviter les fuites de mémoire
    _mariage1Controller.dispose();
    _mariage2Controller.dispose();
    _dateController.dispose();
    _lieuController.dispose();
    _heureController.dispose();
    super.dispose();
  }

  Future<void> _saveMariage() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Créer un objet Mariage avec les données saisies
      final mariage = Mariage(
        userId: widget.userId,
        nomMarie1: _mariage1Controller.text,
        nomMarie2: _mariage2Controller.text,
        date: _dateController.text,
        lieu: _lieuController.text,
        heure: _heureController.text,
      );

      // Sauvegarder dans la base de données
      await _dbHelper.insertMariage(mariage.toMap());

      // Message de succès et retour à la liste des mariages
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mariage créé avec succès !')),
      );

      Navigator.pop(context); // Retour à l'écran précédent
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Création d'un mariage"),
        elevation: 1,
        backgroundColor: Colors.blue,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _mariage1Controller,
                  decoration: InputDecoration(labelText: 'Prénom du Marié'),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Entrez un prénom' : null,
                ),
                TextFormField(
                  controller: _mariage2Controller,
                  decoration: InputDecoration(labelText: 'Prénom de la Marié'),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Entrez un prénom' : null,
                ),
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(labelText: 'Date du Mariage'),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Entrez une date' : null,
                ),
                TextFormField(
                  controller: _lieuController,
                  decoration: InputDecoration(labelText: 'Lieu'),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Entrez un lieu' : null,
                ),
                TextFormField(
                  controller: _heureController,
                  decoration: InputDecoration(labelText: 'Heure'),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Entrez une heure' : null,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveMariage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  ),
                  child: Text('Créer le mariage', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
