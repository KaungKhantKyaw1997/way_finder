import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:way_finder/routes.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Way Finder',
      theme: ThemeData(
        primaryColor: Colors.black,
        primaryColorLight: Colors.black,
        primaryColorDark: Colors.black,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          color: Colors.white,
        ),
        textTheme:
            GoogleFonts.mulishTextTheme(Theme.of(context).textTheme).copyWith(
          displayLarge: GoogleFonts.mulish(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
          displayMedium: GoogleFonts.mulish(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
          displaySmall: GoogleFonts.mulish(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
          headlineLarge: GoogleFonts.mulish(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
          headlineMedium: GoogleFonts.mulish(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
          headlineSmall: GoogleFonts.mulish(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
          titleLarge: GoogleFonts.mulish(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          titleMedium: GoogleFonts.mulish(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          titleSmall: GoogleFonts.mulish(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
          bodyLarge: GoogleFonts.mulish(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          bodyMedium: GoogleFonts.mulish(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          bodySmall: GoogleFonts.mulish(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
          labelLarge: GoogleFonts.mulish(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
          labelMedium: GoogleFonts.mulish(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
          labelSmall: GoogleFonts.mulish(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          hintStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xff7F7F7F),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      initialRoute: Routes.splash,
      routes: Routes.routes,
    );
  }
}
