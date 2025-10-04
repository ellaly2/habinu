import 'package:flutter/material.dart';
import 'data.dart';

class CreateHabit extends StatefulWidget {
  const CreateHabit({Key? key}) : super(key: key);

  @override
  _CreateHabitState createState() => _CreateHabitState();
}

class _CreateHabitState extends State<CreateHabit> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> habits = [];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    setState(() {
      habits = LocalStorage.getHabits();
    });
  }

  Future<void> _addHabit() async {
    if (_controller.text.isNotEmpty) {
      await LocalStorage.addHabit(_controller.text);
      _controller.clear();
      _loadHabits();
    }
  }

  Future<void> _removeHabit(int index) async {
    await LocalStorage.removeHabit(index);
    _loadHabits();
  }

  Future<void> _incrementStreak(int index) async {
    await LocalStorage.incrementStreak(index);
    _loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFFB3B3B3), size: 30),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Text(
                        "Create Habit",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          color: Color(0xFFfdc88f),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: "Habit Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: _addHabit,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFfdc88f),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Your habits:",
                  style: TextStyle(
                    fontSize: 25,
                    color: Color(0xFFfdc88f),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 15),
                habits.isEmpty
                    ? const Text("No habits yet. Add one above!", style: TextStyle(color: Colors.grey))
                    : Column(
                        children: habits.asMap().entries.map((entry) {
                          int index = entry.key;
                          var habit = entry.value;
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEEFF1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _incrementStreak(index),
                                    child: Text(
                                      habit["name"],
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Color(0xFF818181),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      habit["streak"].toString(),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.local_fire_department, color: Colors.orange),
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () => _removeHabit(index),
                                      child: const Icon(Icons.close, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                const SizedBox(height: 30),
                // --- Statistics section ---
                Text(
                  "Stats:\nTotal Habits: ${LocalStorage.getTotalHabits()}\n"
                  "Longest Streak: ${LocalStorage.getLongestStreak()}\n"
                  "Total Posts: ${LocalStorage.getTotalPosts()}\n"
                  "Favourite Habit: ${LocalStorage.getFavouriteHabit()?['name'] ?? 'None'}",
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
