import 'package:flutter/material.dart';
import '../services/progress_service.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
    final bool won = args['won'] ?? false;
    final int score = args['score'] ?? 0;
    final int levelId = args['levelId'] ?? 0;
    final int matches = args['matches'] ?? 0;
    final int mismatches = args['mismatches'] ?? 0;
    final Map<String, dynamic> level = args['level'] ?? {'id': levelId, 'name': 'Unknown', 'rows': 2, 'cols': 4, 'time': 60};

    final int matchPoints = matches * 100;
    final int mismatchPoints = mismatches * -10;
    int breakdownTotal = matchPoints + mismatchPoints;
    if (breakdownTotal < 0) breakdownTotal = 0;

    if (won && levelId > 0) {
      ProgressService.markLevelCompleted(levelId);
    }

    return Scaffold(
      backgroundColor: Color(0xFF9FC9EB),
      appBar: AppBar(
        backgroundColor: Color(0xFF9FC9EB),
        foregroundColor: Colors.black87,
        elevation: 0,
        title: Text('Result'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(won ? 'You Won!' : 'Time\'s up', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Tooltip(
              message: '+100 × $matches = $matchPoints\n-10 × $mismatches = $mismatchPoints\nTotal = $breakdownTotal',
              child: Text('Score: $score', style: TextStyle(fontSize: 20)),
            ),
            SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/levels'),
              child: Text('Back to Levels', style: TextStyle(color: Color(0xFF0000BF))),
            ),
            SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/game', arguments: level),
              child: Text('Play Again', style: TextStyle(color: Color(0xFF0000BF))),
            ),
          ]),
        ),
      ),
    );
  }
}