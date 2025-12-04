import 'package:flutter/material.dart';
import '../services/progress_service.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  final List<Map<String, dynamic>> levels = [
    {'id': 1, 'name': 'Easy', 'rows': 2, 'cols': 4, 'time': 60},
    {'id': 2, 'name': 'Medium', 'rows': 2, 'cols': 6, 'time': 90},
    {'id': 3, 'name': 'Hard', 'rows': 2, 'cols': 7, 'time': 150},
  ];

  Set<int> completed = {};

  @override
  void initState() {
    super.initState();
    completed = ProgressService.getCompletedLevels();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final crossAxisCount = width < 520
        ? 1
        : width < 900
        ? 2
        : 3;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: const Text(
          'Choose Level',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.3),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await ProgressService.resetProgress();
              setState(() => completed = {});
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pick a difficulty and start playing.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    itemCount: levels.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 4 / 3,
                    ),
                    itemBuilder: (_, index) =>
                        _buildLevelCard(context, levels[index]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _mainColor(int id) {
    switch (id) {
      case 1:
        return const Color(0xFF4CAF50);
      case 2:
        return const Color(0xFFFFA726);
      case 3:
      default:
        return const Color(0xFFEF5350);
    }
  }

  String _tagText(int id) {
    switch (id) {
      case 1:
        return 'Relaxed';
      case 2:
        return 'Challenge';
      case 3:
      default:
        return 'Expert';
    }
  }

  Widget _buildLevelCard(BuildContext context, Map<String, dynamic> level) {
    final id = level['id'] as int;
    final name = level['name'] as String;
    final rows = level['rows'] as int;
    final cols = level['cols'] as int;
    final time = level['time'] as int;
    final isCompleted = completed.contains(id);
    final color = _mainColor(id);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      tween: Tween(begin: 0.98, end: 1),
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Material(
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/game', arguments: level).then((_) {
              setState(() {
                completed = ProgressService.getCompletedLevels();
              });
            });
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.94), color.withOpacity(0.78)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -40,
                  bottom: -40,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: Colors.white.withOpacity(0.18),
                            ),
                            child: Text(
                              _tagText(id),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: Colors.white.withOpacity(0.18),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.check_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Done',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          _infoChip(
                            icon: Icons.grid_view_rounded,
                            label: '${rows * cols} cards',
                          ),
                          const SizedBox(width: 8),
                          _infoChip(
                            icon: Icons.timer_rounded,
                            label: '${time}s',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(0.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
