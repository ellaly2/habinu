import 'package:flutter/material.dart';
import 'package:habinu/models/navBar.dart';
import 'package:habinu/models/camera.dart';
import 'package:habinu/models/profile.dart';
import 'package:camera/camera.dart';

class HomePageState extends StatefulWidget {
  const HomePageState({super.key});
  
  @override 
  State<HomePageState> createState() => HomePage();
}

class HomePage extends State<HomePageState> {
  late CameraDescription camera;
  List<Map<String, String>> posts = [
    {
      'imagePath': 'lib/assets/code.png',
      'habit': 'Reading',
      'streak': '5',
      'date': DateTime.now().subtract(Duration(hours: 3)).toString(),
      'username': 'brendan',
    },
    {
      'imagePath': 'lib/assets/piano.png',
      'habit': 'Piano',
      'streak': '15',
      'date': DateTime.now().subtract(Duration(minutes: 15)).toString(),
      'username': 'brendan',
    },
    // Add more posts as needed
  ];

  Future<void> initializeCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    camera = cameras.first;
  }

  @override
  void initState() {
    super.initState();

    initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset('lib/assets/dog-study.png',
             width: 50,
             ),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CameraPageState(camera: camera))
            );
          } else if (index == 2) {
            Navigator.of(
              context,
            ).pushReplacement(NoAnimationPageRoute(page: ProfilePageState()));
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
          padding: const EdgeInsets.only(top: 9.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Image.asset(
                  'lib/assets/panda-profile.png',
                  height: 35,
                  width: 50,
                ),
              ),
              SizedBox(width: 5),
              Text(username, style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Container(
           // Adjust to image size?
          
          decoration: BoxDecoration(color: Colors.grey[300]),
          child: AspectRatio(
            aspectRatio: 1 / 1,
            child: Image.asset(
              imagePath,
              height: 500,
              width: 500,
              fit: BoxFit.cover,
            ),
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
              Row(
                children: [
                  Text(streak, style: TextStyle(fontWeight: FontWeight.w600)),
                  Icon(Icons.local_fire_department, color: Colors.orange),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
