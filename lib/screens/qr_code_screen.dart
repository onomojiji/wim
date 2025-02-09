import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../helpers/database_helper.dart';

class QRScanScreen extends StatefulWidget {
  final int mariageId;

  QRScanScreen({required this.mariageId});

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
    if (_isProcessing) return; // Empêche le traitement multiple
    setState(() => _isProcessing = true);

    // Désactiver temporairement la caméra
    cameraController.stop();

    try {
      final invite = await _dbHelper.getInviteByQRCode(qrCode);

      if (invite != null && invite['mariageId'] == widget.mariageId) {
        int nombrePlaces = invite['nombrePlaces'] ?? 1;
        int nombrePresent = invite['nombrePresent'] ?? 0;

        if (nombrePresent >= nombrePlaces) {
          _showDialog(
            title: '⚠️ Billet complet',
            content:
            'Le billet de ${invite['nom']} couvre déjà $nombrePlaces personnes.\n'
                'Aucune place restante !',
            color: Colors.red,
            dismissible: false,
          );
        } else {
          nombrePresent++;
          await _dbHelper.updatePresence(invite['id'], nombrePresent);

          int placesRestantes = nombrePlaces - nombrePresent;

          _showDialog(
            title: '✅ Bienvenue !',
            content:
            'Mr/Mme ${invite['nom']} \n'
                'Places restantes sur le billet : $placesRestantes',
            color: Colors.green,
            dismissible: false,
          );
        }
      } else {
        _showDialog(
          title: '❌ QR Code invalide',
          content: 'Aucun invité trouvé pour ce QR Code.',
          color: Colors.red,
          dismissible: false,
        );
      }
    } catch (e) {
      if (kDebugMode) print('Erreur : $e');
      _showDialog(
        title: '❌ Erreur',
        content: 'Une erreur est survenue, veuillez réessayer.',
        color: Colors.red,
        dismissible: false,
      );
    }
  }

  void _showDialog({
    required String title,
    required String content,
    required Color color,
    required bool dismissible,
  }) {
    showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(color: color)),
          content: Text(content, style: TextStyle(fontSize: 18)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Ferme le dialogue
                setState(() => _isProcessing = false);
                Future.delayed(Duration(milliseconds: 500), () {
                  cameraController.start(); // Réactiver la caméra
                });
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner un QR Code'),
        actions: [
          IconButton(
            icon: Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: Icon(Icons.cameraswitch),
            onPressed: () => cameraController.switchCamera(),
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
              _handleQRCode(code);
              break; // Traiter un seul QR Code à la fois
            }
          }
        },
      ),
    );
  }
}
