import 'package:flutter/material.dart';
import 'package:expense/widgets/expenses.dart';
// import 'package:flutter/services.dart';

var kColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 96, 59, 181),
);

var kDarkColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 5, 99, 125),
  // brightness: Brightness.dark,
);

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  // ]).then((fn) {
    runApp(MaterialApp(
      home: const Expenses(),
    debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: kDarkColorScheme,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: kDarkColorScheme.onPrimaryContainer,
          foregroundColor: kDarkColorScheme.onPrimary,
        ),
        cardTheme: const CardTheme().copyWith(
          // color: Colors.orange,
          color: kDarkColorScheme.secondaryContainer,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(221, 53, 2, 110),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            //foregroundColor: kColorScheme.onPrimary,
          ),
        ),
        textTheme: ThemeData().textTheme.copyWith(
              titleLarge: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kDarkColorScheme.onPrimary,
              ),
            ),
        iconTheme: IconThemeData(
          color: kDarkColorScheme.secondary,
        ),
      ),
      theme: ThemeData().copyWith(
        colorScheme: kColorScheme,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: kColorScheme.onPrimaryContainer,
          foregroundColor: kColorScheme.onPrimary,
        ),
        cardTheme: const CardTheme().copyWith(
          // color: Colors.orange,
          color: kColorScheme.secondaryContainer,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(221, 49, 21, 68),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            //foregroundColor: kColorScheme.onPrimary,
          ),
        ),
        textTheme: ThemeData().textTheme.copyWith(
              titleLarge: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kColorScheme.onPrimary,
              ),
            ),
        iconTheme: IconThemeData(
          color: kColorScheme.primary.withOpacity(0.65),
        ),
      ),
  ));
  //});

  
    
}
