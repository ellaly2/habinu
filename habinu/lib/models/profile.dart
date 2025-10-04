import 'package:flutter/material.dart';
import 'package:habinu/models/navBar.dart';
import 'package:habinu/models/home.dart';
import 'package:habinu/models/camera.dart';
import 'package:habinu/models/createHabit.dart';

class ProfilePage extends StatelessWidget {
  // Marked fields as final to adhere to immutability requirements
  final String username = 'brendan';
  final Map<String, String> stats = {
    // Insert stats here
    'longestStreak': '9999',
    'totalHabits': '4',
    'habitsPosted': '14',
    'favoriteHabit': 'Brushing Teeth',
  };

  final List<Map<String, dynamic>> habits = [
    {"name": "Meditate", "streak": 5},
    {"name": "Exercise", "streak": 10},
    {"name": "Read", "streak": 36},
  ];

  late final int streak = habits.isNotEmpty
      ? habits.map((h) => h["streak"] as int).reduce((a, b) => a > b ? a : b)
      : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: profileDetails(context),
      bottomNavigationBar: NavBar(
        pageIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(
              context,
            ).pushReplacement(NoAnimationPageRoute(page: HomePage()));
          } else if (index == 1) {
            Navigator.of(
              context,
            ).pushReplacement(NoAnimationPageRoute(page: CameraPage()));
          }
        },
      ),
    );
  }

  Widget profileDetails(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 70),
            profilePic(streak),
            Text(
              username,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 30),
            ),
            statsDisplay(stats),
            SizedBox(height: 20),
            habitList(habits),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => CreateHabit()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFffddb7),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shadowColor: Colors.transparent,
              ),
              child: Text('Edit Habits', style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget habitList(List<Map<String, dynamic>> habits) {
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

  Widget statsDisplay(Map<String, String> stats) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Card(
          color: Color(0xffffddb7),
          shadowColor: Colors.transparent, // Unless we want one!
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Padding(
            padding: const EdgeInsets.only(top: 5.0, left: 5.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Longest Streak",
                    style: TextStyle(fontSize: 12, color: Color(0xff818181)),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        stats['longestStreak'] ?? '0',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      Icon(Icons.local_fire_department, color: Colors.orange),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Card(
          color: Color(0xffffddb7),
          shadowColor: Colors.transparent, // Unless we want one!
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Padding(
            padding: const EdgeInsets.only(top: 5.0, left: 5.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Total Habits",
                    style: TextStyle(fontSize: 12, color: Color(0xff818181)),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    stats['totalHabits'] ?? '0',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
        Card(
          color: Color(0xffffddb7),
          shadowColor: Colors.transparent, // Unless we want one!
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Padding(
            padding: const EdgeInsets.only(top: 5.0, left: 5.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Habits Posted",
                    style: TextStyle(fontSize: 12, color: Color(0xff818181)),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    stats['habitsPosted'] ?? '0',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
        Card(
          color: Color(0xffffddb7),
          shadowColor: Colors.transparent, // Unless we want one!
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Padding(
            padding: const EdgeInsets.only(top: 5.0, left: 5.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Favorite Habit",
                    style: TextStyle(fontSize: 12, color: Color(0xff818181)),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    stats['favoriteHabit'] ?? 'None',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget profilePic(int streak) {
    // In reality would also need input of username or pic
    return SizedBox(
      height: 100,
      width: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'lib/assets/panda-profile.png',
            height: 100,
            width: 100,
            fit: BoxFit.cover,
          ),
          // Icon(Icons.account_circle, size: 80, color: Colors.grey),
          Align(
            alignment: Alignment.bottomRight,
            child: Card(
              color: Color(0xffffddb7),
              // margin: EdgeInsets.all(10),
              shadowColor: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$streak',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.local_fire_department, color: Colors.orange),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
