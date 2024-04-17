// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:way_finder/app.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 3), () async {
      await getLocation();
      Navigator.of(context).pushReplacementNamed('/home');
    });

    return Scaffold(
      body: Center(
        child: Container(
          width: 200,
          height: 200,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/logo.png'),
            ),
            shape: BoxShape.circle,
          ),
          child: const SpinKitWaveSpinner(
            color: Color(0xFF5B55FE),
            waveColor: Colors.transparent,
            trackColor: Color(0xFFDFDFDF),
            size: 200,
          ),
        ),
      ),
    );
  }
}
