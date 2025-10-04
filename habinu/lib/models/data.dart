import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static SharedPreferences? _prefs;
  static const _habitsKey = 'habits';

  /// Initialize SharedPreferences once at app startup
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get all habits (each habit is a Map<String, dynamic>)
  static List<Map<String, dynamic>> getHabits() {
    final String? jsonString = _prefs?.getString(_habitsKey);
    if (jsonString == null) return [];
    final List<dynamic> decoded = jsonDecode(jsonString);
    return List<Map<String, dynamic>>.from(decoded);
  }

  /// Save habits to storage
  static Future<void> _saveHabits(List<Map<String, dynamic>> habits) async {
    final String encoded = jsonEncode(habits);
    await _prefs?.setString(_habitsKey, encoded);
  }

  /// Add a new habit
  static Future<void> addHabit(String name) async {
    final habits = getHabits();
    habits.add({"name": name, "streak": 0, "posted": 0});
    await _saveHabits(habits);
  }

  /// Remove a habit by index
  static Future<void> removeHabit(int index) async {
    final habits = getHabits();
    if (index >= 0 && index < habits.length) {
      habits.removeAt(index);
      await _saveHabits(habits);
    }
  }

  /// Increment streak for a habit
  static Future<void> incrementStreak(int index) async {
    final habits = getHabits();
    if (index >= 0 && index < habits.length) {
      habits[index]["streak"] = (habits[index]["streak"] ?? 0) + 1;
      await _saveHabits(habits);
    }
  }

  /// Increment posted count for a habit
  static Future<void> incrementPosted(int index) async {
    final habits = getHabits();
    if (index >= 0 && index < habits.length) {
      habits[index]["posted"] = (habits[index]["posted"] ?? 0) + 1;
      await _saveHabits(habits);
    }
  }

  /// --- Statistics ---

  /// Total number of habits
  static int getTotalHabits() {
    return getHabits().length;
  }

  /// Total number of posts across all habits
  static int getTotalPosts() {
    final habits = getHabits();
    return habits.fold(0, (sum, h) => sum + ((h["posted"] ?? 0) as int));
  }

  /// Longest streak among all habits
  static int getLongestStreak() {
    final habits = getHabits();
    if (habits.isEmpty) return 0;
    return habits.map((h) => h["streak"] ?? 0).reduce((a, b) => a > b ? a : b);
  }

  /// Favourite habit (one with the highest streak)
  static Map<String, dynamic>? getFavouriteHabit() {
    final habits = getHabits();
    if (habits.isEmpty) return null;
    habits.sort((a, b) => (b["streak"] ?? 0).compareTo(a["streak"] ?? 0));
    return habits.first;
  }

  /// Clear all saved habits
  static Future<void> clear() async {
    await _prefs?.remove(_habitsKey);
  }
}
