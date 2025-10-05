import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static SharedPreferences? _prefs;
  static const _habitsKey = 'habits';
  static const _maxStreakKey = 'maxStreak';
  static const _favoriteHabitKey = 'favoriteHabit';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static List<Map<String, dynamic>> getHabits() {
    final String? jsonString = _prefs?.getString(_habitsKey);
    if (jsonString == null) return [];
    final List<dynamic> decoded = jsonDecode(jsonString);
    return List<Map<String, dynamic>>.from(decoded);
  }

  static Future<void> _saveHabits(List<Map<String, dynamic>> habits) async {
    final String encoded = jsonEncode(habits);
    await _prefs?.setString(_habitsKey, encoded);
  }

  static Future<void> addHabit(String name) async {
    final habits = getHabits();
    habits.add({"name": name, "streak": 0, "posted": 0});
    await _saveHabits(habits);
  }

  static Future<void> removeHabit(int index) async {
    final habits = getHabits();
    if (index >= 0 && index < habits.length) {
      habits.removeAt(index);
      await _saveHabits(habits);
    }
  }

  static Future<void> incrementStreak(int index) async {
    final habits = getHabits();
    if (index >= 0 && index < habits.length) {
      habits[index]["streak"] = (habits[index]["streak"] ?? 0) + 1;
      await _saveHabits(habits);

      // Update persistent global max streak
      int maxStreak = _prefs?.getInt(_maxStreakKey) ?? 0;
      if (habits[index]['streak'] > maxStreak) {
        await _prefs?.setInt(_maxStreakKey, habits[index]['streak']);
        await _prefs?.setString(_favoriteHabitKey, habits[index]['name']);
      }
    }
  }

  static Future<void> incrementPosted(int index) async {
    final habits = getHabits();
    if (index >= 0 && index < habits.length) {
      habits[index]["posted"] = (habits[index]["posted"] ?? 0) + 1;
      await _saveHabits(habits);
    }
  }

  /// --- Statistics ---

  static int getTotalHabits() => getHabits().length;

  static int getTotalPosts() {
    final habits = getHabits();
    return habits.fold(0, (sum, h) => sum + ((h["posted"] ?? 0) as int));
  }

  /// Longest streak: use global max if habits list is empty
  static int getLongestStreak() {
    final habits = getHabits();
    if (habits.isEmpty) {
      return _prefs?.getInt(_maxStreakKey) ?? 0;
    }
    int currentMax = habits.map((h) => h["streak"] ?? 0).reduce((a, b) => a > b ? a : b);
    int globalMax = _prefs?.getInt(_maxStreakKey) ?? 0;
    return currentMax > globalMax ? currentMax : globalMax;
  }

  /// Favourite habit: use saved one if habits list is empty
  static Map<String, dynamic>? getFavouriteHabit() {
    final String? name = _prefs?.getString(_favoriteHabitKey);
    final int maxStreak = _prefs?.getInt(_maxStreakKey) ?? 0;

    if (name == null) return null;
    return {"name": name, "streak": maxStreak};
  }


  static Future<void> clear() async {
    await _prefs?.remove(_habitsKey);
    // optionally, keep max streak/favorite habit
    // await _prefs?.remove(_maxStreakKey);
    // await _prefs?.remove(_favoriteHabitKey);
  }
}
