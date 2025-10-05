import 'package:flutter/material.dart';
import 'package:habinu/models/navBar.dart';
import 'package:habinu/models/camera.dart';
import 'package:habinu/models/profile.dart';
import 'package:habinu/models/data.dart';
import 'package:camera/camera.dart';
import 'dart:io';

class HomePageState extends StatefulWidget {
  const HomePageState({super.key});

  @override
  State<HomePageState> createState() => HomePage();
}

class HomePage extends State<HomePageState> {
  late CameraDescription camera;
  List<Map<String, dynamic>> posts = [];

  Future<void> initializeCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    camera = cameras.first;
  }

  Future<void> _loadPosts() async {
    setState(() {
      posts = LocalStorage.getAllPostsSorted();
    });
  }

  @override
  void initState() {
    super.initState();
    initializeCamera();
    _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset('lib/assets/dog-study.png', width: 50),
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
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_forever,
              color: Colors.red,
              size: 24,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Clear All Data'),
                    content: const Text(
                      'This will delete all habits and posts. This action cannot be undone.\n\nAre you sure?'
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await LocalStorage.clear();
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            _loadPosts(); // Refresh the UI
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('All data cleared!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Delete All',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            tooltip: 'Clear all data (Debug)',
          ),
        ],
      ),
      body: postsList(),
      bottomNavigationBar: NavBar(
        pageIndex: 0,
        onTap: (index) {
          if (index == 0) {
            // Refresh posts when home tab is tapped
            _loadPosts();
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CameraPageState(camera: camera),
              ),
            ).then(
              (_) => _loadPosts(),
            ); // Refresh posts when returning from camera
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
    if (posts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 64, color: Color(0xFFB3B3B3)),
            SizedBox(height: 16),
            Text(
              "No posts yet!",
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFFB3B3B3),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Take a photo and post it to a habit to see it here.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFFB3B3B3)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final postData = posts[index];

        return post(
          imagePath: postData['imagePath'] ?? '',
          habit: postData['habit'] ?? 'Unknown Habit',
          streak: postData['streak'] ?? '0',
          date: DateTime.parse(postData['date'] ?? DateTime.now().toString()),
          username: postData['username'] ?? 'Unknown',
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
            child: File(imagePath).existsSync()
                ? Image.file(
                    File(imagePath),
                    height: 500,
                    width: 500,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 500,
                    width: 500,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 64,
                    ),
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
