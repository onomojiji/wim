import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:wim/configs/colors.dart';
import 'package:wim/configs/screen.dart';
import 'package:wim/screens/qr_code_screen.dart';
import '../helpers/database_helper.dart';

class InvitesListScreen extends StatefulWidget {
  final int mariageId;
  final String nomMariage;

  const InvitesListScreen({
    super.key,
    required this.mariageId,
    required this.nomMariage,
  });

  @override
  State<InvitesListScreen> createState() => _InvitesListScreenState();
}

class _InvitesListScreenState extends State<InvitesListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _invites = [];
  bool _isLoading = false; // State to track if the loader is active

  @override
  void initState() {
    super.initState();
    _loadInvites();
  }

  Future<void> _loadInvites() async {
    final invites = await _dbHelper.getInvites(widget.mariageId);
    setState(() {
      _invites = invites;
    });
  }

  Future<void> _importInvites() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      setState(() {
        _isLoading = true; // Activate loader
      });

      File file = File(result.files.single.path!);
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows.skip(1)) {
          final String nom = "${row[0]?.value}";
          final String prenom = "${row[1]?.value}";
          final String qrCode = "${row[2]?.value}";

          final existingInvite = await _dbHelper.getInviteByQRCode(qrCode);
          if (existingInvite != null) {
            await _handleDuplicateInvite(existingInvite, {
              'mariageId': widget.mariageId,
              'nom': nom,
              'prenom': prenom,
              'qrCode': qrCode,
            });
          } else {
            await _dbHelper.insertInvite({
              'mariageId': widget.mariageId,
              'nom': nom,
              'prenom': prenom,
              'qrCode': qrCode,
            });
          }
        }
      }

      await _loadInvites(); // Reload the invites list after import

      setState(() {
        _isLoading = false; // Deactivate loader
      });
    }
  }

  Future<void> _handleDuplicateInvite(
      Map<String, dynamic> existingInvite,
      Map<String, dynamic> newInvite,
      ) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Invité déjà existant'),
          content: Text(
            'L\'invité ${existingInvite['nom']} ${existingInvite['prenom']} existe déjà.\n'
                'Voulez-vous écraser ses informations ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Ignorer'),
            ),
            TextButton(
              onPressed: () async {
                await _dbHelper.updateInvite(existingInvite['id'], newInvite);
                Navigator.pop(context);
              },
              child: Text('Écraser'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _scanQRCode() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScanScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(widget.nomMariage),
            actions: [
              IconButton(
                icon: Icon(Icons.sim_card_download_outlined),
                onPressed: _importInvites,
              ),
              IconButton(
                icon: Icon(Icons.upload_file),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.delete_sweep_outlined),
                onPressed: () {},
              ),
            ],
          ),
          body: Container(
            color: Colors.grey[200],
            child: Column(
              children: [
                if (_invites.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.group, size: hauteur(context, 100), color: Colors.grey),
                          SizedBox(height: hauteur(context, 20)),
                          Text(
                            'Aucun invité trouvé.',
                            style: TextStyle(
                              fontSize: hauteur(context, 14),
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text('Importez-en pour commencer !'),
                        ],
                      ),
                    ),
                  )
                else ...[
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: hauteur(context, 10), horizontal: largeur(context, 10)),
                    child: Text(
                      '${_invites.length} invités',
                      style: TextStyle(
                        fontSize: hauteur(context, 20),
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(bottom: 80),
                      itemCount: _invites.length,
                      itemBuilder: (context, index) {
                        final invite = _invites[index];
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(largeur(context, 5)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 2,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text('${invite['nom']} ${invite['prenom']}'),
                            subtitle: Text('QR Code : ${invite['qrCode']}'),
                            trailing: invite['presence'] == 'présent'
                                ? Icon(Icons.check_circle, color: Colors.green)
                                : Icon(Icons.radio_button_unchecked,
                                color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _scanQRCode,
            backgroundColor: secondaryColor,
            child: Icon(Icons.qr_code, color: Colors.white),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
