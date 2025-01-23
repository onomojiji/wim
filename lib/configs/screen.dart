import 'package:flutter/widgets.dart';

double screenHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double screenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double hauteur(BuildContext context, double value) {
  return screenHeight(context) * value / myHeight;
}

double largeur(BuildContext context, double value) {
  return screenWidth(context) * value / myWidth;
}

const double myHeight = 720.0;
const double myWidth = 360.0;