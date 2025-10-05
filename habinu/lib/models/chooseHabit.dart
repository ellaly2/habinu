import 'package:flutter/material.dart';
import 'package:habinu/models/createHabit.dart';
import 'package:habinu/models/data.dart';

class ChooseHabit extends StatefulWidget {
  const ChooseHabit({Key? key}) : super(key: key);

  @override
  _ChooseHabitState createState() => _ChooseHabitState();
}

class _ChooseHabitState extends State<ChooseHabit> {
  late List<Map<String, dynamic>> habits;

  @override
  void initState() {
    super.initState();
    habits = LocalStorage.getHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Your habits:",
          style: TextStyle(
            fontSize: 25,
            color: Color(0xFFfdc88f),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 15),
        habits.isEmpty
            ? Text(
                "No habits yet. Add one below!",
                style: TextStyle(color: Colors.grey),
              )
            : Column(
                children: habits.asMap().entries.map((entry) {
                  var habit = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFeeeff1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              child: Text(
                                habit["name"],
                                style: TextStyle(
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
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.local_fire_department,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }
}
