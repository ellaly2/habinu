import 'package:flutter/material.dart';
import 'package:habinu/models/profile.dart';
import 'package:habinu/models/data.dart';

class CreateFirstHabit extends StatefulWidget {
  const CreateFirstHabit({Key? key}) : super(key: key);

  @override
  _CreateFirstHabitState createState() => _CreateFirstHabitState();
}

class _CreateFirstHabitState extends State<CreateFirstHabit> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> habits = []; // Load from file

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
                  "Create First Habit",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    color: Color(0xFFfdc88f),
                    fontWeight: FontWeight.w900,
                  ),
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
                    onTap: () {
                      String habitName = _controller.text.trim();
                      if (habitName.isNotEmpty) {
                        LocalStorage.addHabit(habitName);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => ProfilePageState(),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFfdc88f),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        'Next',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
