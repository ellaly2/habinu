import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static SharedPreferences? _prefs;
  static const _habitsKey = 'habits';
  static const _postsKey = 'posts';
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

  /// Gets habits and ensures streaks are up to date
  static Future<List<Map<String, dynamic>>> getHabitsWithValidation() async {
    await validateAndUpdateStreaks();
    return getHabits();
  }

  /// Checks if a habit was updated today
  static bool wasHabitUpdatedToday(Map<String, dynamic> habit) {
    final lastUpdatedStr = habit["lastUpdated"] as String?;

    if (lastUpdatedStr == null || lastUpdatedStr == "never") {
      return false;
    }

    try {
      final lastUpdated = DateTime.parse(lastUpdatedStr);
      final today = DateTime.now();

      // Check if both dates are on the same day
      return lastUpdated.year == today.year &&
          lastUpdated.month == today.month &&
          lastUpdated.day == today.day;
    } catch (e) {
      return false;
    }
  }

  static List<Map<String, dynamic>> getPosts() {
    final String? jsonString = _prefs?.getString(_postsKey);
    if (jsonString == null) return [];
    final List<dynamic> decoded = jsonDecode(jsonString);
    return List<Map<String, dynamic>>.from(decoded);
  }

  static Future<void> _saveHabits(List<Map<String, dynamic>> habits) async {
    final String encoded = jsonEncode(habits);
    await _prefs?.setString(_habitsKey, encoded);
  }

  static Future<void> _savePosts(List<Map<String, dynamic>> posts) async {
    final String encoded = jsonEncode(posts);
    await _prefs?.setString(_postsKey, encoded);
  }

  static Future<void> addHabit(String name) async {
    final habits = getHabits();
    habits.add({
      "name": name,
      "streak": 0,
      "posted": 0,
      "lastUpdated": "never", // Set to "never" so new habits don't get reset
    });
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

  /// Validates streaks and resets them if 2 or more days have passed since last update
  static Future<void> validateAndUpdateStreaks() async {
    final habits = getHabits();
    bool needsUpdate = false;
    final now = DateTime.now();

    for (int i = 0; i < habits.length; i++) {
      final habit = habits[i];
      final lastUpdatedStr = habit["lastUpdated"] as String?;

      if (lastUpdatedStr != null && lastUpdatedStr != "never") {
        try {
          final lastUpdated = DateTime.parse(lastUpdatedStr);
          final daysDifference = now.difference(lastUpdated).inDays;

          // If 2 or more days have passed, reset streak
          if (daysDifference >= 2) {
            habits[i]["streak"] = 0;
            needsUpdate = true;
          }
        } catch (e) {
          // If parsing fails, reset streak and update date
          habits[i]["streak"] = 0;
          habits[i]["lastUpdated"] = now.toIso8601String();
          needsUpdate = true;
        }
      } else if (lastUpdatedStr == null) {
        // If no lastUpdated field exists, add it as "never" and keep current streak
        habits[i]["lastUpdated"] = "never";
        needsUpdate = true;
      }
      // If lastUpdated is "never", don't reset the streak - leave it as is
    }

    if (needsUpdate) {
      await _saveHabits(habits);
    }
  }

  /// Increments streak for a habit and updates the last updated date
  static Future<void> incrementStreakForPost(int index) async {
    final habits = getHabits();
    if (index >= 0 && index < habits.length) {
      final now = DateTime.now();
      final lastUpdatedStr = habits[index]["lastUpdated"] as String?;

      // Check if we can increment the streak (same day or next day)
      bool canIncrement = true;
      if (lastUpdatedStr != null && lastUpdatedStr != "never") {
        try {
          final lastUpdated = DateTime.parse(lastUpdatedStr);
          final daysDifference = now.difference(lastUpdated).inDays;

          // If posting on the same day, don't increment streak
          if (daysDifference == 0) {
            canIncrement = false;
          }
          // If 2 or more days gap, reset to 1 (new streak starts)
          else if (daysDifference >= 2) {
            habits[index]["streak"] = 1;
            canIncrement = false;
          }
        } catch (e) {
          // If parsing fails, start fresh
          habits[index]["streak"] = 1;
          canIncrement = false;
        }
      }

      // Increment streak if it's the next day
      if (canIncrement) {
        habits[index]["streak"] = (habits[index]["streak"] ?? 0) + 1;
      }

      // Always update the last updated date
      habits[index]["lastUpdated"] = now.toIso8601String();

      await _saveHabits(habits);

      // Update persistent global max streak
      int maxStreak = _prefs?.getInt(_maxStreakKey) ?? 0;
      if (habits[index]['streak'] > maxStreak) {
        await _prefs?.setInt(_maxStreakKey, habits[index]['streak']);
        await _prefs?.setString(_favoriteHabitKey, habits[index]['name']);
      }
    }
  }

  static Future<void> addPost(String habitName, String imagePath) async {
    final posts = getPosts();
    final habits = await getHabitsWithValidation();

    // Find the current streak for this habit
    final habit = habits.firstWhere(
      (h) => h["name"] == habitName,
      orElse: () => {"streak": 0},
    );

    posts.add({
      "imagePath": imagePath,
      "habit": habitName,
      "streak": habit["streak"].toString(),
      "date": DateTime.now().toString(),
      "username": "You", // For now, but ready for multi-user in future
    });

    await _savePosts(posts);
  }

  static List<Map<String, dynamic>> getPostsForHabit(String habitName) {
    final posts = getPosts();
    return posts.where((post) => post["habit"] == habitName).toList();
  }

  static List<Map<String, dynamic>> getAllPostsSorted() {
    final posts = getPosts();
    posts.sort((a, b) {
      try {
        final dateA = DateTime.parse(a["date"] ?? "");
        final dateB = DateTime.parse(b["date"] ?? "");
        return dateB.compareTo(dateA); // Most recent first
      } catch (e) {
        return 0; // If parsing fails, maintain current order
      }
    });
    return posts;
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
    int currentMax = habits
        .map((h) => h["streak"] ?? 0)
        .reduce((a, b) => a > b ? a : b);
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
    await _prefs?.remove(_postsKey);
    // optionally, keep max streak/favorite habit
    // await _prefs?.remove(_maxStreakKey);
    // await _prefs?.remove(_favoriteHabitKey);
  }
}
