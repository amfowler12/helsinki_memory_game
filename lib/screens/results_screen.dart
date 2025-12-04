import 'package:flutter/material.dart';
import '../services/progress_service.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ??
        {};
    final bool won = args['won'] ?? false;
    final int score = args['score'] ?? 0;
    final int levelId = args['levelId'] ?? 0;
    final int matches = args['matches'] ?? 0;
    final int mismatches = args['mismatches'] ?? 0;
    final Map<String, dynamic> level =
        args['level'] ??
        {'id': levelId, 'name': 'Unknown', 'rows': 2, 'cols': 4, 'time': 60};

    final int matchPoints = matches * 100;
    final int mismatchPoints = mismatches * -10;
    int breakdownTotal = matchPoints + mismatchPoints;
    if (breakdownTotal < 0) breakdownTotal = 0;

    if (won && levelId > 0) {
      ProgressService.markLevelCompleted(levelId);
    }

    final Color bg = const Color(0xFF020617);
    final Color cardBgTop = const Color(0xFF0B1120);
    final Color cardBgBottom = const Color(0xFF020617);
    final Color borderColor = const Color(0xFF1F2937);
    final Color accent = const Color(0xFF38BDF8);
    final Color success = const Color(0xFF22C55E);
    final Color danger = const Color(0xFFEF4444);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Result',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.3),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: Colors.transparent,
                    elevation: 18,
                    shadowColor: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: LinearGradient(
                          colors: [cardBgTop, cardBgBottom],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        border: Border.all(color: borderColor, width: 1.2),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            won ? Icons.emoji_events : Icons.hourglass_bottom,
                            size: 40,
                            color: won ? success : danger,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            won ? 'You Won!' : "Time's up",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: won ? Colors.white : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Level: ${level['name']} • '
                            '${level['rows']} x ${level['cols']} • '
                            '${level['time']}s',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '$score',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: accent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Total Score',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF020617),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF111827),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildRow(
                                  label: 'Matches',
                                  value: 'x$matches  (+$matchPoints)',
                                  color: success,
                                ),
                                const SizedBox(height: 8),
                                _buildRow(
                                  label: 'Mismatches',
                                  value: 'x$mismatches  ($mismatchPoints)',
                                  color: mismatchPoints == 0
                                      ? const Color(0xFF9CA3AF)
                                      : danger,
                                ),
                                const Divider(
                                  height: 18,
                                  color: Color(0xFF1F2937),
                                ),
                                _buildRow(
                                  label: 'Score from cards',
                                  value: '$breakdownTotal',
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: accent.withOpacity(0.7)),
                            foregroundColor: accent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            '/levels',
                          ),
                          child: const Text('Back to Levels'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            '/game',
                            arguments: level,
                          ),
                          child: const Text('Play Again'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow({
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
