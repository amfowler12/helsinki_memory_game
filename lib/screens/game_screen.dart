import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/memory_game.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final level = args ?? {'id': 1, 'name': 'Easy', 'rows': 2, 'cols': 2, 'time': 60};

    final MemoryGame game = MemoryGame(
      levelId: level['id'],
      rows: level['rows'],
      cols: level['cols'],
      timeLimit: level['time'],
      onGameOver: (won, score, matches, mismatches) {
        Navigator.pushReplacementNamed(context, '/result', arguments: {
          'won': won,
          'score': score,
          'levelId': level['id'],
          'level': level,
          'matches': matches,
          'mismatches': mismatches,
        });
      },
    );

    final maxWidth = 1200.0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE2EFFA),
        foregroundColor: Colors.black87,
        elevation: 0,
        title: Text('Level: ${level['name']}'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                color: Colors.blueGrey[50],
                child: GameWidget(game: game),
              );
            },
          ),
        ),
      ),
    );
  }
}