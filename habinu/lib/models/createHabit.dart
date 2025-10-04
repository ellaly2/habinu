import 'package:flutter/material.dart';

class CreateHabit extends StatefulWidget {
  @override
  _CreateHabitState createState() => _CreateHabitState();
}

class _CreateHabitState extends State<CreateHabit> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> habits = [];

  void _addHabit() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        habits.add({
          "name": _controller.text,
          "streak": 0,
        });
        _controller.clear();
      });
    }
  }

  void _removeHabit(int index) {
    setState(() {
      habits.removeAt(index);
    });
  }

  void _incrementStreak(int index) {
    setState(() {
      habits[index]["streak"]++;
    });
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
                Text(
                  "Create Habit",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFFfdc88f),
                    fontWeight: FontWeight.w600,
                  ),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Color(0xFFfdc88f),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
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
                Text(
                  "Your habits:",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFFfdc88f),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 15),
                habits.isEmpty
                    ? Text(
                        "No habits yet. Add one above!",
                        style: TextStyle(color: Colors.grey),
                      )
                    : Column(
                        children: habits.asMap().entries.map((entry) {
                          int index = entry.key;
                          var habit = entry.value;
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Color(0xFFEEEFF1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _incrementStreak(index),
                                    child: Text(
                                      habit["name"],
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      habit["streak"].toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(Icons.local_fire_department,
                                        color: Colors.orange),
                                    SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () => _removeHabit(index),
                                      child: Icon(Icons.close,
                                          color: Colors.white),
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
