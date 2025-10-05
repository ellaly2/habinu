import 'package:flutter/material.dart';
import 'package:habinu/models/data.dart';
import 'dart:io';

class ChooseHabit extends StatefulWidget {
  final String? imagePath;

  const ChooseHabit({Key? key, this.imagePath}) : super(key: key);

  @override
  _ChooseHabitState createState() => _ChooseHabitState();
}

class _ChooseHabitState extends State<ChooseHabit> {
  late List<Map<String, dynamic>> habits;
  int? selected; // Index of the selected habit, null if none selected
  bool isNewHabitSelected = false; // True when text field is selected
  final TextEditingController _newHabitController = TextEditingController();
  final FocusNode _newHabitFocusNode = FocusNode();

  Future<void> _refreshHabits() async {
    final validatedHabits = await LocalStorage.getHabitsWithValidation();
    setState(() {
      habits = validatedHabits;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshHabits();

    // Add listener to focus node to update selection state
    _newHabitFocusNode.addListener(() {
      if (_newHabitFocusNode.hasFocus) {
        setState(() {
          selected = null;
          isNewHabitSelected = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _newHabitController.dispose();
    _newHabitFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFFB3B3B3),
            size: 30,
          ),
          onPressed: () {
            // Pop twice to skip the preview screen and go back to main camera
            Navigator.of(context).pop(); // Pop ChooseHabit
            Navigator.of(context).pop(); // Pop DisplayPictureScreen
          },
        ),
        title: const Text(
          "Choose Habit",
          style: TextStyle(
            fontSize: 25,
            color: Color(0xFFfdc88f),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 15),
                      Column(
                        children: [
                          ...habits.asMap().entries.map((entry) {
                            int index = entry.key;
                            var habit = entry.value;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selected = index;
                                  isNewHabitSelected = false;
                                });
                                _newHabitFocusNode.unfocus();
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: selected == index
                                      ? const Color(0xFFfdc88f).withAlpha(50)
                                      : const Color(0xFFEEEFF1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selected == index
                                        ? const Color(0xFFfdc88f)
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        habit["name"],
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: selected == index
                                              ? const Color(0xFF666666)
                                              : const Color(0xFF818181),
                                          fontWeight: FontWeight.w700,
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
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 5),
                          // New habit text field
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selected = null;
                                isNewHabitSelected = true;
                              });
                              _newHabitFocusNode.requestFocus();
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: isNewHabitSelected
                                    ? const Color(0xFFfdc88f).withAlpha(50)
                                    : const Color(0xFFF4F4F6),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isNewHabitSelected
                                      ? const Color(0xFFfdc88f)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: TextField(
                                controller: _newHabitController,
                                focusNode: _newHabitFocusNode,
                                cursorColor: Color(0xfffbb86a),
                                decoration: const InputDecoration(
                                  hintText: "Enter new habit...",
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFF818181),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Color(0xFF666666),
                                  fontWeight: FontWeight.w700,
                                ),
                                onTap: () {
                                  setState(() {
                                    selected = null;
                                    isNewHabitSelected = true;
                                  });
                                },
                                onChanged: (value) {
                                  setState(() {
                                    if (value.isNotEmpty) {
                                      selected = null;
                                      isNewHabitSelected = true;
                                    }
                                    // Always call setState to update button state
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Image preview (if imagePath is provided)
                              if (widget.imagePath != null) imagePreview(),
                              // Post button
                              postButton(context),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container imagePreview() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFfdc88f), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(File(widget.imagePath!), fit: BoxFit.cover),
      ),
    );
  }

  SizedBox postButton(BuildContext context) {
    // Enable button if either a habit is selected OR new habit text is entered
    bool isEnabled =
        selected != null ||
        (isNewHabitSelected && _newHabitController.text.trim().isNotEmpty);

    return SizedBox(
      height: 45,
      child: ElevatedButton(
        onPressed: isEnabled
            ? () async {
                // Handle the post action here
                if (widget.imagePath != null) {
                  String habitName;
                  int habitIndex;

                  if (isNewHabitSelected &&
                      _newHabitController.text.trim().isNotEmpty) {
                    // Create new habit first
                    habitName = _newHabitController.text.trim();
                    await LocalStorage.addHabit(habitName);

                    // Refresh habits to get the new one
                    await _refreshHabits();

                    // Find the index of the newly created habit
                    habitIndex = habits.indexWhere(
                      (h) => h["name"] == habitName,
                    );
                  } else if (selected != null) {
                    // Use existing selected habit
                    final selectedHabit = habits[selected!];
                    habitName = selectedHabit["name"];
                    habitIndex = selected!;
                  } else {
                    return; // Should not happen due to isEnabled check
                  }

                  // Increment streak and update lastUpdated date first
                  await LocalStorage.incrementStreakForPost(habitIndex);

                  // Add the post to storage (now with updated streak)
                  await LocalStorage.addPost(habitName, widget.imagePath!);

                  // Increment the posted counter for the habit
                  await LocalStorage.incrementPosted(habitIndex);

                  // Show success message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Posted for $habitName!'),
                        backgroundColor: const Color(0xFFfdc88f),
                        duration: const Duration(seconds: 2),
                      ),
                    );

                    // Navigate back to main camera or home
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                } else {
                  // Handle case where no image is provided
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No image to post!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            : null, // Button is disabled when nothing is selected
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFfdc88f),
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          "Post",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
