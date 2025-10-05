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
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _loadHabits();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadHabits() async {
    final validatedHabits = await LocalStorage.getHabitsWithValidation();
    setState(() {
      habits = validatedHabits;
    });
  }

  Future<void> _addHabit() async {
    if (_controller.text.isNotEmpty) {
      await LocalStorage.addHabit(_controller.text);
      _controller.clear();
      _loadHabits();
    }
  }

  Future<void> _showDeleteConfirmation(int index) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Habit'),
          content: Text(
            'Are you sure you want to delete "${habits[index]["name"]}"?',
          ),
          backgroundColor: Colors.white,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _removeHabit(index);
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
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFFB3B3B3),
                        size: 30,
                      ),
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
                  cursorColor: Color(0xfffbb86a),
                  decoration: InputDecoration(
                    labelText: "Habit Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xfffbb86a),
                        width: 2.0,
                      ),
                    ),
                    labelStyle: const TextStyle(color: Color(0xff818181)),
                  ),
                ),
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: _hasText ? _addHabit : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _hasText ? const Color(0xFFfdc88f) : Colors.grey,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Manage Habits",
                  style: TextStyle(
                    fontSize: 25,
                    color: Color(0xFFfdc88f),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 15),
                habits.isEmpty
                    ? const Text(
                        "No habits yet. Add one above!",
                        style: TextStyle(color: Colors.grey),
                      )
                    : Column(
                        children: habits.asMap().entries.map((entry) {
                          int index = entry.key;
                          var habit = entry.value;
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 15,
                            ),
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
                                    Icon(
                                      Icons.local_fire_department,
                                      color:
                                          LocalStorage.wasHabitUpdatedToday(
                                            habit,
                                          )
                                          ? Colors.orange
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () =>
                                          _showDeleteConfirmation(index),
                                      child: const Icon(
                                        Icons.close,
                                        color: Color.fromARGB(
                                          255,
                                          255,
                                          153,
                                          153,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
