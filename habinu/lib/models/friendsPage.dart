import 'package:flutter/material.dart';
import 'package:habinu/models/profile.dart';
import 'package:habinu/models/navBar.dart';
import 'package:habinu/models/home.dart';
import 'package:habinu/models/camera.dart';
import 'package:habinu/models/notificationsPage.dart';
import 'package:camera/camera.dart';
import 'package:habinu/models/searchPage.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<Map<String, String>> friends = [
    {'username': 'mochi', 'icon': 'lib/assets/panda-profile.png'},
  ];

  late CameraDescription camera;
  bool hasNotifications = false;

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

  @override
  void initState() {
    super.initState();
    initializeCamera();
    setState(() {
      hasNotifications = getNotifications().isNotEmpty;
    });
  }

  Future<void> _showRemoveConfirmation(int index) async {
    final bool? shouldRemove = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Friend'),
          content: Text(
            'Are you sure you want to remove "${friends[index]["username"]}" from your friends list?',
          ),
          backgroundColor: Colors.white,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldRemove == true) {
      _removeFriend(index);
    }
  }

  void _removeFriend(int index) {
    setState(() {
      friends.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset('lib/assets/dog-smile.png', width: 50),
            Text(
              'My Friends',
              style: TextStyle(
                color: Color(0xffffc88d),
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              child: Image.asset('lib/assets/add-friends.png', width: 30),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchPage()),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 5, width: double.infinity),
                friends.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: friends.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFeeeff1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Image.asset(friends[index]['icon']!),
                              title: Text(friends[index]['username']!),
                              trailing: GestureDetector(
                                onTap: () => _showRemoveConfirmation(index),
                                child: const Icon(
                                  Icons.close,
                                  color: Color.fromARGB(255, 255, 153, 153),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Column(
                        children: [
                          SizedBox(height: 50),
                          Text("You have no friends added yet."),
                          SizedBox(height: 200),
                          Image.asset('lib/assets/dog-huh.png', width: 150),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavBar(
        pageIndex: 1,
        hasNotifications: hasNotifications,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacement(
              NoAnimationPageRoute(page: const HomePageState()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CameraPageState(camera: camera),
              ),
            );
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
}
