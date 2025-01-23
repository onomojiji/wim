import 'package:flutter/material.dart';
import 'package:wim/configs/colors.dart';
import 'package:wim/screens/create_mariage_screen.dart';
import 'package:wim/screens/invites_list_screen.dart';
import 'package:wim/screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wedding Invite Manager',
      theme: ThemeData(
          appBarTheme: AppBarTheme(
              color: secondaryColor,
            iconTheme: IconThemeData(color: whiteColor),
            elevation: 1,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          primaryColor: secondaryColor,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => SplashScreen());
          case '/home':
            return MaterialPageRoute(builder: (context) => HomeScreen());
          case '/create-mariage':
            if (settings.arguments is int) {
              final userId = settings.arguments as int;
              return MaterialPageRoute(
                builder: (context) => CreateMariageScreen(userId: userId),
              );
            }
            return _errorRoute();
          case '/invites-list':
            if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>;
              final mariageId = args['mariageId'] as int;
              final nomMariage = args['nomMariage'] as String;
              return MaterialPageRoute(
                builder: (context) => InvitesListScreen(
                  mariageId: mariageId,
                  nomMariage: nomMariage,
                ),
              );
            }
            return _errorRoute();
          case '/login':
            return MaterialPageRoute(builder: (context) => LoginScreen());
          default:
            return _errorRoute();
        }
      },
    );
  }

  /// Route d'erreur
  Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: Text('Erreur')),
        body: Center(child: Text('Page non trouvée')),
      ),
    );
  }
}
