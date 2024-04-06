// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:way_finder/app.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 3), () async {
      // await getLocation();
      Navigator.of(context).pushReplacementNamed('/home');
    });

    return MaterialApp(
      home: Scaffold(
        body: Container(),
      ),
    );
  }
}
