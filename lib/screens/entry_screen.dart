import 'package:flutter/material.dart';

class EntryScreen extends StatelessWidget {
  const EntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 300,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/calculator1'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[400],
                    padding: const EdgeInsets.all(8.0),
                  ),
                  child: const Text(
                    'Завдання 1',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 300,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/calculator2'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[400],
                    padding: const EdgeInsets.all(8.0),
                  ),
                  child: const Text(
                    'Завдання 2',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
