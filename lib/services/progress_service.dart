import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static late SharedPreferences _prefs;
  static const String _key = 'completed_levels';

  static Future<void> initialize(SharedPreferences prefs) async {
    _prefs = prefs;
  }

  static Set<int> getCompletedLevels() {
    final list = _prefs.getStringList(_key) ?? [];
    return list.map((e) => int.tryParse(e) ?? -1).where((v) => v >= 0).toSet();
  }

  static Future<void> markLevelCompleted(int levelId) async {
    final set = getCompletedLevels();
    set.add(levelId);
    await _prefs.setStringList(_key, set.map((e) => e.toString()).toList());
  }

  static Future<void> resetProgress() async {
    await _prefs.remove(_key);
  }
}