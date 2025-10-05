import 'package:flutter/material.dart';
import 'package:habinu/models/navBar.dart';
import 'package:habinu/models/camera.dart';
import 'package:habinu/models/profile.dart';
import 'package:habinu/models/notificationsPage.dart';
import 'package:habinu/models/data.dart';
import 'package:camera/camera.dart';
import 'package:habinu/models/friendsPage.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';

class HomePageState extends StatefulWidget {
  const HomePageState({super.key});

  @override
  State<HomePageState> createState() => HomePage();
}

class HomePage extends State<HomePageState> with TickerProviderStateMixin {
  late CameraDescription camera;
  List<Map<String, dynamic>> posts = [];
  bool hasNotifications = false;

  // Animation controllers for stamp effects
  final Map<int, AnimationController> _wiggleControllers = {};
  final Map<int, AnimationController> _colorControllers = {};
  final Map<int, bool> _stampClicked = {};

  // Sample notifications check - you can modify this to match your notification logic
  List<Map<String, String>> getNotifications() {
    return [
      {
        'type': 'endorsement',
        'icon': 'lib/assets/panda-profile.png',
        'from': 'mochi',
        'habit': 'Daily Jogging',
        'timestamp': DateTime.now().subtract(Duration(hours: 2)).toString(),
      },
      {
        'type': 'request',
        'icon': 'lib/assets/ditto.png',
        'from': 'DanielTheManiel',
        'timestamp': DateTime.now().subtract(Duration(days: 1)).toString(),
      },
    ];
  }

  Future<void> initializeCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    camera = cameras.first;
  }

  Future<void> _loadPosts() async {
    // Validate habits first to ensure streaks are up to date
    await LocalStorage.validateAndUpdateStreaks();
    setState(() {
      posts = LocalStorage.getAllPostsSorted();
    });
  }

  @override
  void initState() {
    super.initState();
    initializeCamera();
    _loadPosts();
    setState(() {
      hasNotifications = getNotifications().isNotEmpty;
    });
  }

  @override
  void dispose() {
    // Dispose all animation controllers
    for (final controller in _wiggleControllers.values) {
      controller.dispose();
    }
    for (final controller in _colorControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Get or create wiggle animation controller for a specific post
  AnimationController _getWiggleController(int postIndex) {
    if (!_wiggleControllers.containsKey(postIndex)) {
      _wiggleControllers[postIndex] = AnimationController(
        duration: Duration(milliseconds: 500),
        vsync: this,
      );
    }
    return _wiggleControllers[postIndex]!;
  }

  // Get or create color animation controller for a specific post
  AnimationController _getColorController(int postIndex) {
    if (!_colorControllers.containsKey(postIndex)) {
      _colorControllers[postIndex] = AnimationController(
        duration: Duration(milliseconds: 300),
        vsync: this,
      );
    }
    return _colorControllers[postIndex]!;
  }

  // Handle stamp click with animation
  void _onStampTap(int postIndex) {
    setState(() {
      _stampClicked[postIndex] = true;
    });

    final wiggleController = _getWiggleController(postIndex);
    final colorController = _getColorController(postIndex);

    // Start stamp animations
    wiggleController.forward().then((_) {
      wiggleController.reverse();
    });
    colorController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(
              Icons.auto_awesome,
              color: Color(0xfffdc88f),
              size: 24,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Load Template Data'),
                    content: const Text(
                      'This will load sample posts from mochi and DanielTheManiel. Any existing data will be replaced.\n\nContinue?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await LocalStorage.loadTemplateData();
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            _loadPosts(); // Refresh the UI
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Template data loaded!'),
                                backgroundColor: Color(0xfffdc88f),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Load Template',
                          style: TextStyle(color: Color(0xfffdc88f)),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            tooltip: 'Load template data',
          ),
        ],
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
      ),
      body: postsList(),
      bottomNavigationBar: NavBar(
        pageIndex: 0,
        hasNotifications: hasNotifications,
        onTap: (index) {
          if (index == 0) {
            // Refresh posts when home tab is tapped
            _loadPosts();
          } else if (index == 1) {
            Navigator.of(
              context,
            ).pushReplacement(NoAnimationPageRoute(page: const FriendsPage()));
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CameraPageState(camera: camera),
              ),
            ).then(
              (_) => _loadPosts(),
            ); // Refresh posts when returning from camera
          } else if (index == 3) {
            Navigator.of(context).pushReplacement(
              NoAnimationPageRoute(page: NotificationPageState()),
            );
          } else if (index == 4) {
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
          profilePicPath:
              postData['profilePic'] ?? 'lib/assets/panda-profile.png',
          index: index,
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
    required int index,
    required String profilePicPath,
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
                child: Image.asset(profilePicPath, height: 35, width: 50),
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
            child: imagePath.startsWith('lib/assets/')
                ? Image.asset(
                    imagePath,
                    height: 500,
                    width: 500,
                    fit: BoxFit.cover,
                  )
                : File(imagePath).existsSync()
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
              // Animated stamp with wiggle and color effects
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => _onStampTap(index),
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _getWiggleController(index),
                      _getColorController(index),
                    ]),
                    builder: (context, child) {
                      final wiggleController = _getWiggleController(index);
                      final colorController = _getColorController(index);

                      // Wiggle animation (rotation)
                      final wiggleAnimation =
                          Tween<double>(
                            begin: 0.0,
                            end: 0.1, // Small rotation for wiggle effect
                          ).animate(
                            CurvedAnimation(
                              parent: wiggleController,
                              curve: Curves.elasticOut,
                            ),
                          );

                      // Color animation (fade to orange)
                      final colorAnimation =
                          ColorTween(
                            begin: null, // Keep original color
                            end: Color(0xfffbb86a),
                          ).animate(
                            CurvedAnimation(
                              parent: colorController,
                              curve: Curves.easeInOut,
                            ),
                          );

                      return Transform.rotate(
                        angle: wiggleAnimation.value,
                        child: ColorFiltered(
                          colorFilter:
                              _stampClicked[index] == true &&
                                  colorAnimation.value != null
                              ? ColorFilter.mode(
                                  colorAnimation.value!,
                                  BlendMode.srcATop,
                                )
                              : ColorFilter.mode(
                                  Colors.transparent,
                                  BlendMode.dst,
                                ),
                          child: SvgPicture.asset(
                            'lib/assets/stamp.svg',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
