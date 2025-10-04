import 'package:flutter/material.dart';
import 'package:habinu/models/navBar.dart';
import 'package:habinu/models/home.dart';
import 'package:habinu/models/camera.dart';

class ProfilePage extends StatelessWidget {
  // Marked fields as final to adhere to immutability requirements
  final int streak = 69;
  final String username = 'brendan';
  final Map<String, String> stats = {
    // Insert stats here
    'Longest Streak': '9999🔥',
    'Total Habits': '35',
    'Friends': '14',
    'Favorite Habit': 'Brushing Teeth',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: profileDetails(),
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

  Center profileDetails() {
    return Center(
      child: Column(
        children: [profilePic(streak), Text(username), statsDisplay(stats)],
      ),
    );
  }

  GridView statsDisplay(Map<String, String> stats) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(4, (index) {
        return Card(
          color: Color(0xffffddb7),
          shadowColor: Colors.transparent, // Unless we want one!
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    stats.keys.elementAt(index),
                    style: TextStyle(fontSize: 12, color: Color(0xff818181)),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    stats.values.elementAt(index),
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  SizedBox profilePic(int streak) {
    // In reality would also need input of username or pic
    return SizedBox(
      height: 100,
      width: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset('lib/assets/panda-profile.png', height: 150, width: 150),
          // Icon(Icons.account_circle, size: 80, color: Colors.grey),
          Align(
            alignment: Alignment.bottomRight,
            child: Card(
              color: Color(0xffffddb7),
              margin: EdgeInsets.all(10),
              shadowColor: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  '$streak🔥',
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
