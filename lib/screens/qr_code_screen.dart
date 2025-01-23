import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../helpers/database_helper.dart';

class QRScanScreen extends StatefulWidget {
  @override
  _QRScanScreenState createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  MobileScannerController cameraController = MobileScannerController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isProcessing = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _handleQRCode(String qrCode) async {
    // Empêcher le traitement multiple des mêmes données scannées
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    try {
      // Rechercher l'invité dans la base de données
      final invite = await _dbHelper.getInviteByQRCode(qrCode);

      if (invite != null) {
        // Afficher les informations de l'invité dans une boîte de dialogue
        await showDialog(
          context: context,
          barrierDismissible: false, // Empêche la fermeture sans interaction
          builder: (context) {
            return AlertDialog(
              title: Text('Invité trouvé'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Nom : ${invite['nom']}'),
                  Text('Prénom : ${invite['prenom']}'),
                  Text('QR Code : ${invite['qrCode']}'),
                  Text('Présence : ${invite['presence']}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    // Mettre à jour la présence de l'invité
                    await _dbHelper.updatePresence(invite['id'], 'présent');
                    Navigator.pop(context); // Fermer la boîte de dialogue
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Afficher un message si l'invité n'est pas trouvé
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aucun invité trouvé pour ce QR Code.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du traitement du QR Code : $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Une erreur est survenue. Veuillez réessayer.'),
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      // Réinitialiser le traitement
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner un QR Code'),
        actions: [
          IconButton(
            icon: Icon(Icons.flash_on),
            onPressed: () {
              cameraController.toggleTorch();
            },
          ),
          IconButton(
            icon: Icon(Icons.cameraswitch),
            onPressed: () {
              cameraController.switchCamera();
            },
          ),
        ],
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            final String? code = barcode.rawValue;
            if (code != null) {
              _handleQRCode(code); // Traiter le QR Code scanné
              break; // Traiter un seul QR Code à la fois
            }
          }
        },
      ),
    );
  }
}
