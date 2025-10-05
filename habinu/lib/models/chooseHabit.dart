import 'package:flutter/material.dart';
import 'package:habinu/models/createHabit.dart';
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

  Future<void> _refreshHabits() async {
    setState(() {
      habits = LocalStorage.getHabits();
    });
  }

  @override
  void initState() {
    super.initState();
    habits = LocalStorage.getHabits();
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
                      habits.isEmpty
                          ? const Text(
                              "No habits yet.",
                              style: TextStyle(color: Colors.grey),
                            )
                          : Column(
                              children: [
                                ...habits.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  var habit = entry.value;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selected = index;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 5,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 15,
                                      ),
                                      decoration: BoxDecoration(
                                        color: selected == index
                                            ? const Color(
                                                0xFFfdc88f,
                                              ).withAlpha(50)
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
                                              const Icon(
                                                Icons.local_fire_department,
                                                color: Colors.orange,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Image preview (if imagePath is provided)
                                    if (widget.imagePath != null)
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFfdc88f),
                                            width: 2,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          child: Image.file(
                                            File(widget.imagePath!),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    // Post button
                                    SizedBox(
                                      height: 45,
                                      child: ElevatedButton(
                                        onPressed: selected != null
                                            ? () async {
                                                // Handle the post action here
                                                if (widget.imagePath != null) {
                                                  final selectedHabit =
                                                      habits[selected!];

                                                  // Add the post to storage
                                                  await LocalStorage.addPost(
                                                    selectedHabit["name"],
                                                    widget.imagePath!,
                                                  );

                                                  // Increment the posted counter for the habit
                                                  await LocalStorage.incrementPosted(
                                                    selected!,
                                                  );

                                                  // Show success message
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Posted for ${selectedHabit["name"]}!',
                                                        ),
                                                        backgroundColor:
                                                            const Color(
                                                              0xFFfdc88f,
                                                            ),
                                                        duration:
                                                            const Duration(
                                                              seconds: 2,
                                                            ),
                                                      ),
                                                    );

                                                    // Navigate back to main camera or home
                                                    Navigator.of(
                                                      context,
                                                    ).popUntil(
                                                      (route) => route.isFirst,
                                                    );
                                                  }
                                                } else {
                                                  // Handle case where no image is provided
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'No image to post!',
                                                        ),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  }
                                                }
                                              }
                                            : null, // Button is disabled when no habit is selected
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFfdc88f,
                                          ),
                                          disabledBackgroundColor:
                                              Colors.grey.shade300,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
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
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 60),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 45,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (_) => const CreateHabit(),
                            ),
                          )
                          .then((_) => _refreshHabits());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFffddb7).withAlpha(150),
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Create New Habit",
                          style: TextStyle(
                            color: Color(0xFF818181),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.add, color: Color(0xFF818181)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
