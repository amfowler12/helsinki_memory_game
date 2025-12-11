import 'package:flutter/material.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final maxWidth = 900.0;
    return Scaffold(
      body: Container(
        color: Color(0xFF9FC9EB),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/Art.png',
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Helsinki Memory',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Arial',
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Find matching pairs of Helsinki landmarks. Train your memory and learn the city!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Arial'),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/levels'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Color(0xFF0000BF),
                      side: BorderSide(color: Color(0xFF0000BF), width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      child: Text(
                        'Start',
                        style: TextStyle(fontSize: 18, fontFamily: 'Arial'),
                      ),
                    ),
                  ),
                  SizedBox(height: 18),
                  Text(
                    'Tip: works on touch devices — tap cards to flip.',
                    style: TextStyle(fontFamily: 'Arial'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
