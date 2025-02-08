import 'package:flutter/material.dart';
import 'screens/calculator1_screen.dart';
import 'screens/calculator2_screen.dart';
import 'screens/entry_screen.dart';

void main() {
  runApp(const MyApp());
}

// можливі роутери
enum Routes { mainScreen, calculator1, calculator2 }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Калькулятор',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/':
            page = const EntryScreen();
            break;
          case '/calculator1':
            page = const Calculator1Screen();
            break;
          case '/calculator2':
            page = const Calculator2Screen();
            break;
          default:
            page = const EntryScreen();
        }
        return MaterialPageRoute(builder: (context) => page);
      },
    );
  }
}
