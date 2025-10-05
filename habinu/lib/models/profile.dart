import 'package:flutter/material.dart';
import 'package:habinu/models/data.dart';
import 'package:habinu/models/navBar.dart';
import 'package:habinu/models/home.dart';
import 'package:habinu/models/camera.dart';
import 'package:habinu/models/createHabit.dart';
import 'package:camera/camera.dart';

class ProfilePageState extends StatefulWidget {
  ProfilePageState({super.key});
  // Marked fields as final to adhere to immutability requirements
  final String username = 'brendan';
  final Map<String, String> stats = {
    // Insert stats here
    'longestStreak': '9999',
    'totalHabits': '4',
    'habitsPosted': '14',
    'favoriteHabit': 'Brushing Teeth',
  };

  @override
  State<ProfilePageState> createState() => ProfilePage();
}

class ProfilePage extends State<ProfilePageState> {
  late CameraDescription camera;
  List<Map<String, dynamic>> habits = [];
  String username = 'brendan';

  @override
  void initState() {
    super.initState();
    _loadHabits();
    initializeCamera();
  }

  Future<void> _loadHabits() async {
    final validatedHabits = await LocalStorage.getHabitsWithValidation();
    setState(() {
      habits = validatedHabits;
    });
  }

  Future<void> _incrementStreak(int index) async {
    await LocalStorage.incrementStreak(index);
    _loadHabits();
  }

  Future<void> _removeHabit(int index) async {
    await LocalStorage.removeHabit(index);
    _loadHabits();
  }

  Map<String, String> get stats => {
    'longestStreak': LocalStorage.getLongestStreak().toString(),
    'totalHabits': LocalStorage.getTotalHabits().toString(),
    'habitsPosted': LocalStorage.getTotalPosts().toString(),
    'favoriteHabit': LocalStorage.getFavouriteHabit()?['name'] ?? 'None',
  };

  Future<void> initializeCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    camera = cameras.first;
  }

  @override
  Widget build(BuildContext context) {
    int streak = habits.isNotEmpty
        ? habits.map((h) => h["streak"] as int).reduce((a, b) => a > b ? a : b)
        : 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _profileDetails(context, streak),
      bottomNavigationBar: NavBar(
        pageIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(
              context,
            ).pushReplacement(NoAnimationPageRoute(page: HomePageState()));
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CameraPageState(camera: camera),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _profileDetails(BuildContext context, int streak) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 70),
            _profilePic(streak),
            Text(
              username,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 30),
            ),
            _statsDisplay(stats),
            const SizedBox(height: 20),
            _habitList(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(builder: (_) => const CreateHabit()),
                    )
                    .then((_) => _loadHabits());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFffddb7),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shadowColor: Colors.transparent,
              ),
              child: const Text('Edit Habits', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _habitList() {
    return Column(
      children: [
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
            ? const Text(
                "No habits yet. Add one below!",
                style: TextStyle(color: Colors.grey),
              )
            : Column(
                children: habits.asMap().entries.map((entry) {
                  int index = entry.key;
                  var habit = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFeeeff1),
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
                                color: LocalStorage.wasHabitUpdatedToday(habit)
                                    ? Colors.orange
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 10),
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

  Widget _statsDisplay(Map<String, String> stats) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _statCard("Longest Streak", stats['longestStreak'] ?? '0', true),
        _statCard("Total Habits", stats['totalHabits'] ?? '0', false),
        _statCard("Habits Posted", stats['habitsPosted'] ?? '0', false),
        _statCard("Favorite Habit", stats['favoriteHabit'] ?? 'None', false),
      ],
    );
  }

  Widget _statCard(String title, String value, bool hasFire) {
    return Card(
      color: const Color(0xffffddb7),
      shadowColor: Colors.transparent,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0, left: 5.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(fontSize: 12, color: Color(0xff818181)),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    value,
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  if (hasFire)
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profilePic(int streak) {
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
          Align(
            alignment: Alignment.bottomRight,
            child: Card(
              color: const Color(0xffffddb7),
              shadowColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$streak',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                    ),
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
