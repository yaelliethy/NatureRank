import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:equinox/equinox.dart';
import 'package:NatureRank/baseView.dart';

import 'package:page_transition/page_transition.dart';
void main() {
  runApp(NatureRank());
}

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: 'assets/logo.png',
      nextScreen: BaseView(),
      splashTransition: SplashTransition.slideTransition,
      pageTransitionType: PageTransitionType.leftToRight,
    );
  }
}
class NatureRank extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return EquinoxApp(
      theme: EqThemes.defaultLightTheme,
      title: 'NatureRank',
      home: Splash(),
    );
  }
}

