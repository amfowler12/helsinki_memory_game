import 'package:flutter/material.dart';
import '../services/progress_service.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  _LevelSelectScreenState createState() => _LevelSelectScreenState();
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
    final maxWidth = 1100.0;
    final isNarrow = MediaQuery.of(context).size.width < 600; // breakpoint example
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE2EFFA),
        foregroundColor: Colors.black87,
        elevation: 0,
        title: Text('Choose Level'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              await ProgressService.resetProgress();
              setState(() {
                completed = {};
              });
            },
            tooltip: 'Reset progress',
          )
        ],
      ),
      body: Container(
        color: Color(0xFFE2EFFA),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: isNarrow ? _buildList() : _buildGrid(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView(
      children: levels.map(_buildLevelTile).toList(),
    );
  }

  Widget _buildGrid() {
    return ListView(
      children: levels.map(_buildLevelTile).toList(),
    );
  }

  Widget _buildLevelTile(Map<String, dynamic> level) {
    final id = level['id'] as int;
    final completedFlag = completed.contains(id);
    return Card(
      elevation: 4,
      color: Colors.white,
      child: SizedBox(
        height: 120,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/game', arguments: level).then((_) {
              setState(() {
                completed = ProgressService.getCompletedLevels();
              });
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(level['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('${level['rows']} x ${level['cols']} cards'),
                    SizedBox(height: 8),
                    Text('Time: ${level['time']}s'),
                  ],
                ),
              ),
              if (completedFlag) Icon(Icons.check_circle, color: Colors.blue, size: 32),
            ],
          ),
        ),
      ),
    ));
  }
}