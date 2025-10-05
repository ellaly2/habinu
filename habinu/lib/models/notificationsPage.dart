import 'package:flutter/material.dart';
import 'package:habinu/models/navBar.dart';
import 'package:habinu/models/home.dart';
import 'package:habinu/models/camera.dart';
import 'package:habinu/models/profile.dart';
import 'package:camera/camera.dart';
import 'package:habinu/models/friendsPage.dart';

class NotificationPageState extends StatefulWidget {
  const NotificationPageState({super.key});

  @override
  State<NotificationPageState> createState() => NotificationStatePage();
}

class NotificationStatePage extends State<NotificationPageState> {
  late CameraDescription camera;

  List<Map<String, String>> notifications = [
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

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    camera = cameras.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset('lib/assets/dog-magnify.png', width: 50),
            Text(
              'Notifications',
              style: TextStyle(
                color: Color(0xffffc88d),
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 5, width: double.infinity),
                notifications.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Stack(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFeeeff1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Image.asset(
                                      notifications[index]['icon']!,
                                    ),
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notifications[index]['type'] ==
                                                  'endorsement'
                                              ? 'New Endorsement'
                                              : 'Friend Request',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          notifications[index]['type'] ==
                                                  'endorsement'
                                              ? '${notifications[index]['from']} endorsed "${notifications[index]['habit']}"'
                                              : '${notifications[index]['from']} sent you a friend request',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    trailing:
                                        notifications[index]['type'] ==
                                            'request'
                                        ? ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                // HANDLE FRIEND REQUEST ACCEPTANCE
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(
                                                0xFFffddb7,
                                              ),
                                              shadowColor: Colors.transparent,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 5,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Text(
                                              'Accept',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                                // Floating X button in top-left corner
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        notifications.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: Color(
                                          0xfffbb86a,
                                        ).withOpacity(0.8),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.2,
                                            ),
                                            offset: Offset(0, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : Column(
                        children: [
                          SizedBox(height: 50),
                          Text("No new notifications."),
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
        pageIndex: 3,
        hasNotifications: notifications.isNotEmpty,
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
          } else if (index == 1) {
            Navigator.of(
              context,
            ).pushReplacement(NoAnimationPageRoute(page: FriendsPage()));
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
