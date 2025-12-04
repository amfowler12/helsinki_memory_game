import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/memory_game.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final level =
        args ?? {'id': 1, 'name': 'Easy', 'rows': 2, 'cols': 4, 'time': 60};

    final game = MemoryGame(
      levelId: level['id'] as int,
      rows: level['rows'] as int,
      cols: level['cols'] as int,
      timeLimit: level['time'] as int,
      onGameOver: (won, score, matches, mismatches) {
        Navigator.pushReplacementNamed(
          context,
          '/result',
          arguments: {
            'won': won,
            'score': score,
            'matches': matches,
            'mismatches': mismatches,
            'levelId': level['id'],
            'level': level,
          },
        );
      },
    );

    const maxWidth = 1100.0;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Level: ${level['name']}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${level['rows']} x ${level['cols']}  •  ${level['time']}s',
              style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;
                  final screenAspect = w / h;
                  const targetAspect = 16 / 9;

                  final bool useFixedAspect = screenAspect > targetAspect + 0.1;

                  Widget content = GameWidget(game: game);

                  if (useFixedAspect) {
                    content = AspectRatio(
                      aspectRatio: targetAspect,
                      child: content,
                    );
                  } else {
                    // 在窄屏上稍微留一点边距，避免顶到边
                    content = Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: content,
                    );
                  }

                  return Center(
                    child: Material(
                      color: Colors.transparent,
                      elevation: 18,
                      shadowColor: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(32),
                      child: Container(
                        width: useFixedAspect ? null : w,
                        height: useFixedAspect ? null : h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0B1120), Color(0xFF020617)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          border: Border.all(
                            color: const Color(0xFF1F2937),
                            width: 1.2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: content,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
