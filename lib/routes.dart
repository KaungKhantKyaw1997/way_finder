import 'package:flutter/material.dart';
import 'package:way_finder/screens/splash_screen.dart';
import 'package:way_finder/screens/home_screen.dart';

class Routes {
  static const String splash = '/splash';
  static const String home = '/home';

  static final Map<String, WidgetBuilder> routes = {
    splash: (BuildContext context) => const SplashScreen(),
    home: (BuildContext context) => const HomeScreen(),
  };
}
