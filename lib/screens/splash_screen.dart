

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
              ));
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  height: hauteur(context, 250),
                  width: largeur(context, 250),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/logos/logo_wim.png"),
                    ),
                  )
              ),
              Text("Wedding Invitations Manager", style: TextStyle(fontSize: hauteur(context, 20), fontWeight: FontWeight.normal, color: secondaryColor),)
            ],
          )
      ),
    );
  }
}
