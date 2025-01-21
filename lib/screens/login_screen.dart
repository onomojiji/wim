import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKeyLogin = GlobalKey<FormState>();
  final _formKeySignup = GlobalKey<FormState>();
  final _pseudoLoginController = TextEditingController();
  final _pinLoginController = TextEditingController();
  final _pseudoSignupController = TextEditingController();
  final _pinSignupController = TextEditingController();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Hachage du mot de passe
  String _hashPassword(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }

  /// Validation et connexion
  Future<void> _login() async {
    if (_formKeyLogin.currentState!.validate()) {
      String pseudo = _pseudoLoginController.text;
      String hashedPin = _hashPassword(_pinLoginController.text);

      // Vérification dans la base de données
      final result = await _dbHelper.getUtilisateurs();
      final user = result.firstWhere(
            (u) => u['pseudo'] == pseudo && u['pin'] == hashedPin,
        orElse: () => {},
      );

      _pseudoSignupController.clear();
      _pinSignupController.clear();

      // Échec : Afficher un message d'erreur
      if (user.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pseudo ou PIN incorrect')),
        );
      }else{
        // Succès : Rediriger vers la page principale
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connexion réussie')),
        );
        // Redirection ici
        Navigator.pushNamed(context, '/home');
      }

    }
  }

  /// Validation et inscription
  Future<void> _signup() async {
    if (_formKeySignup.currentState!.validate()) {
      String pseudo = _pseudoSignupController.text;
      String hashedPin = _hashPassword(_pinSignupController.text);

      // Insertion dans la base de données
      final utilisateur = {'pseudo': pseudo, 'pin': hashedPin};
      await _dbHelper.insertUtilisateur(utilisateur);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inscription réussie, connectez-vous')),
      );
      _pseudoSignupController.clear();
      _pinSignupController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connexion & Inscription')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Connexion', style: Theme.of(context).textTheme.titleLarge),
              Form(
                key: _formKeyLogin,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _pseudoLoginController,
                      decoration: InputDecoration(labelText: 'Pseudo'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Entrez un pseudo valide';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _pinLoginController,
                      decoration: InputDecoration(labelText: 'PIN'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.length < 4) {
                          return 'Le PIN doit contenir au moins 4 caractères';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _login,
                      child: Text('Se connecter'),
                    ),
                  ],
                ),
              ),
              Divider(height: 40),
              Text('Inscription', style: Theme.of(context).textTheme.titleLarge),
              Form(
                key: _formKeySignup,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _pseudoSignupController,
                      decoration: InputDecoration(labelText: 'Pseudo'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Entrez un pseudo valide';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _pinSignupController,
                      decoration: InputDecoration(labelText: 'PIN'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.length < 4) {
                          return 'Le PIN doit contenir au moins 4 caractères';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _signup,
                      child: Text('S\'inscrire'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
