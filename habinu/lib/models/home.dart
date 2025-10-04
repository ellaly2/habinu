import 'package:flutter/material.dart';
import 'package:habinu/models/navBar.dart';
import 'package:habinu/models/camera.dart';
import 'package:habinu/models/profile.dart';

class HomePage extends StatelessWidget {
  List<Map<String, String>> posts = [
    {
      'imagePath': 'lib/assets/dog-study.png',
      'habit': 'Reading',
      'streak': '5',
      'date': DateTime.now().subtract(Duration(hours: 3)).toString(),
      'username': 'brendan',
    },
    {
      'imagePath': 'lib/assets/dog-check.png',
      'habit': 'Piano',
      'streak': '15',
      'date': DateTime.now().subtract(Duration(minutes: 15)).toString(),
      'username': 'brendan',
    },
    // Add more posts as needed
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('lib/assets/dog-study.png'),
            Text(
              'Habinu',
              style: TextStyle(
                color: Color(0xffffc88d),
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
          ],
        ),
      ),
      body: postsList(),
      bottomNavigationBar: NavBar(
        pageIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.of(
              context,
            ).pushReplacement(NoAnimationPageRoute(page: CameraPage()));
          } else if (index == 2) {
            Navigator.of(
              context,
            ).pushReplacement(NoAnimationPageRoute(page: ProfilePage()));
          }
        },
      ),
    );
  }

  Widget postsList() {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final postData = posts[index];
        return post(
          imagePath: postData['imagePath']!,
          habit: postData['habit']!,
          streak: postData['streak']!,
          date: DateTime.parse(postData['date']!),
          username: postData['username']!,
        );
      },
    );
  }

  Widget post({
    required String imagePath,
    required String habit,
    required String streak,
    required DateTime date,
    required String username,
    // required String profilePicPath,
  }) {
    String timeAgo = '';
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays > 8) {
      timeAgo = '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays >= 1) {
      timeAgo = '${difference.inDays} days ago';
    } else if (difference.inHours >= 1) {
      timeAgo = '${difference.inHours} hours ago';
    } else if (difference.inMinutes >= 1) {
      timeAgo = '${difference.inMinutes} minutes ago';
    } else {
      timeAgo = 'Just now';
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Image.asset(
                'lib/assets/panda-profile.png',
                height: 35,
                width: 35,
              ),
              SizedBox(width: 5),
              Text(username, style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Container(
          height: 500, // Adjust to image size?
          width: 500,
          decoration: BoxDecoration(color: Colors.grey[300]),
          child: Image.asset(
            imagePath,
            height: 500,
            width: 500,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(habit, style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(timeAgo, style: TextStyle(color: Color(0xff818181))),
                ],
              ),
              Text(streak, style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
