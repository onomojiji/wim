import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:wim/screens/qr_code_screen.dart';
import '../configs/colors.dart';
import '../configs/screen.dart';
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
  bool _isLoading = false;
  int nmbreInvites = 0;
  int nbrePresentInvites = 0;

  @override
  void initState() {
    super.initState();
    _loadInvites();
    _totalInvites();
    _totalInvitesPresent();
  }

  Future<void> _loadInvites() async {
    final invites = await _dbHelper.getInvites(widget.mariageId);
    setState(() {
      _invites = invites;
    });
  }

  //int _getTotalPresentInvites() {
    //return _invites.fold<int>(0, (total, invite) => total + (invite['nombrePresent'] is int ? invite['nombrePresent'] : 0));
  //}

  Future<void> _totalInvites() async{
    final totalInvites = await _dbHelper.getInviteCount(widget.mariageId);

    setState(() {
      nmbreInvites = totalInvites;
    });
  }

  Future<void> _totalInvitesPresent() async{
    final totalPresentInvites = await _dbHelper.getPresentInvite(widget.mariageId);

    setState(() {
      nbrePresentInvites = totalPresentInvites;
    });
  }

  Future<void> _importInvites() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      setState(() {
        _isLoading = true;
      });

      File file = File(result.files.single.path!);
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows.skip(1)) {
          final String nomPorteur = row[0]?.value.toString() ?? "";
          final String ville = row[1]?.value.toString() ?? "";
          final String nom = row[2]?.value.toString() ?? "";
          final String telephone = row[3]?.value.toString() ?? "";
          final int nombrePlaces = int.tryParse(row[4]?.value.toString() ?? "1") ?? 1;
          final String qrCode = row[5]?.value.toString() ?? "";

          final existingInvite = await _dbHelper.getInviteByQRCode(qrCode);
          if (existingInvite != null) {
            // réccupère l'id du mariage de l'invité présent dans la bd
            int existingMariageId = existingInvite["mariageId"];

            if (existingMariageId != widget.mariageId){
              await _dbHelper.insertInvite({
                'mariageId': widget.mariageId,
                'nomPorteur': nomPorteur,
                'ville': ville,
                'nom': nom,
                'telephone': telephone,
                'nombrePlaces': nombrePlaces,
                'qrCode': qrCode,
              });
            }else{
              // pass
              continue;
            }
          } else {
            await _dbHelper.insertInvite({
              'mariageId': widget.mariageId,
              'nomPorteur': nomPorteur,
              'ville': ville,
              'nom': nom,
              'telephone': telephone,
              'nombrePlaces': nombrePlaces,
              'qrCode': qrCode,
            });
          }
        }
      }

      await _loadInvites();

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _exportInvites() async {
    final excel = Excel.createExcel();
    final sheet = excel['Invités'];

    sheet.appendRow([
      TextCellValue('Nom du Porteur'),
      TextCellValue('Ville'),
      TextCellValue('Nom'),
      TextCellValue('Téléphone'),
      TextCellValue('Nombre de Places'),
      TextCellValue('QR Code'),
      TextCellValue('Présents'),
    ]);

    for (var invite in _invites) {
      sheet.appendRow([
        TextCellValue(invite['nomPorteur']),
        TextCellValue(invite['ville']),
        TextCellValue(invite['nom']),
        TextCellValue(invite['telephone']),
        IntCellValue(invite['nombrePlaces']),
        TextCellValue(invite['qrCode']),
        TextCellValue('${invite['nombrePresent']}/${invite['nombrePlaces']}'),
      ]);
    }

    final directory = await Directory.systemTemp.createTemp();
    final String filePath = '${directory.path}/invites.xlsx';
    final List<int>? fileBytes = excel.encode();
    final file = File(filePath);
    await file.writeAsBytes(fileBytes!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Liste exportée : $filePath'),
        duration: Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Ouvrir',
          onPressed: () {
            File(filePath).open();
          },
        ),
      ),
    );
  }

  Future<void> _scanQRCode() async {
    Navigator.pushNamed(
      context,
      '/qrcode-scanner',
      arguments: widget.mariageId,
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
                onPressed: _exportInvites,
              ),
            ],
          ),
          body: Container(
            color: Colors.grey[200],
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: hauteur(context, 10),
                    horizontal: largeur(context, 10),
                  ),
                  child: Text(
                    '$nmbreInvites invités - $nbrePresentInvites présents',
                    style: TextStyle(
                      fontSize: hauteur(context, 15),
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 80),
                    itemCount: _invites.length,
                    itemBuilder: (context, index) {
                      final invite = _invites[index];
                      final int nombrePlaces = invite['nombrePlaces'] ?? 1;
                      final int nombrePresent = invite['nombrePresent'] ?? 0;
                      final bool complet = nombrePresent == nombrePlaces;

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
                          title: Text('${invite['nom']} ($nombrePresent/$nombrePlaces présents)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                          subtitle: Text('De ${invite['ville']}'),
                          trailing: complet
                              ? Icon(Icons.check_circle, color: Colors.green)
                              : Icon(Icons.radio_button_unchecked, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
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
            color: Colors.black.withOpacity(0.5),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
