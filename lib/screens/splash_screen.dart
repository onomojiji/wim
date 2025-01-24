import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wim/configs/colors.dart';
import 'package:wim/screens/home_screen.dart';

import '../configs/screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 3),
          () {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Logo centré
          Center(
            child: Container(
              height: hauteur(context, 400),
              width: largeur(context, 400),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/logos/logo_wim_splash.png"),
                ),
              ),
            ),
          ),
          // Loader en bas avec padding
          Positioned(
            bottom: hauteur(context, 30), // Distance depuis le bas de la page
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator(
                color: secondaryColor, // Personnalisation de la couleur
              ),
            ),
          ),
        ],
      ),
    );
  }
}
