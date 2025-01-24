import 'package:flutter/material.dart';
import 'package:wim/configs/colors.dart';
import 'package:wim/configs/screen.dart';
import '../helpers/database_helper.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _mariages = [];

  @override
  void initState() {
    super.initState();
    _loadMariages();
  }

  /// Charger les mariages de l'utilisateur
  Future<void> _loadMariages() async {
    final mariages = await _dbHelper.getMariages();
    setState(() {
      _mariages = mariages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
      ),
      body: _mariages.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group, size: hauteur(context, 100), color: Colors.grey),
            SizedBox(height: hauteur(context, 20)),
            Text(
              'Aucun mariage trouvé.',
              style: TextStyle(
                fontSize: hauteur(context, 14),
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const Text('Créez-en pour commencer !'),
          ],
        ),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: largeur(context, 13), vertical: hauteur(context, 10)),
            child: Text(
              'Sélectionnez un mariage pour gérer les invités :',
              style: TextStyle(
                fontSize: hauteur(context, 12),
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _mariages.length,
              itemBuilder: (context, index) {
                final mariage = _mariages[index];
                return Container(
                  margin: EdgeInsets.symmetric(
                      vertical: hauteur(context, 5), horizontal: largeur(context, 10)),
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(hauteur(context, 5)),
                    border: Border.all(color: secondaryColor, width: largeur(context, 1)),
                  ),
                  child: ListTile(
                    title: Text(
                      '${mariage['nomMarie1']} & ${mariage['nomMarie2']}',
                      style: TextStyle(
                          fontSize: hauteur(context, 12), fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Lieu : ${mariage['lieu']}\nDate : ${mariage['date']}',
                      style: TextStyle(fontSize: hauteur(context, 12)),
                    ),
                    isThreeLine: true,
                    onTap: () {
                      // Ouvrir la liste des invités
                      Navigator.pushNamed(
                        context,
                        '/invites-list',
                        arguments: {
                          'mariageId': mariage['id'],
                          'nomMariage': '${mariage['nomMarie1']} & ${mariage['nomMarie2']}',
                        },
                      );
                    },
                    leading: CircleAvatar(
                      radius: 30,
                      child:
                      Text('${mariage['nomMarie1'][0]}/${mariage['nomMarie2'][0]}'),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                        size: hauteur(context, 20),
                      ),
                      onPressed: () async {
                        // demander confirmation avant de supprimer
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Supprimer le mariage'),
                            content: const Text(
                                'Voulez-vous vraiment supprimer ce mariage ? \n\nCela supprimera également tous les invités associés.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Annuler',
                                    style: TextStyle(color: secondaryColor)),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await _dbHelper.deleteMariage(mariage['id']);
                                  _loadMariages(); // Recharger les mariages après suppression
                                },
                                child: const Text('Supprimer',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create-mariage', arguments: 1).then((_) {
            _loadMariages(); // Recharger les mariages après création
          });
        },
        tooltip: 'Créer un nouveau mariage',
        backgroundColor: secondaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
