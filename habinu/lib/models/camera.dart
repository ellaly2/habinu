import 'package:flutter/material.dart';
import 'package:habinu/models/navBar.dart';
import 'package:habinu/models/home.dart';
import 'package:habinu/models/profile.dart';

class CameraPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera Page')),
      body: Center(child: Text('Welcome to the Camera Page!')),
      bottomNavigationBar: NavBar(
        pageIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(
              context,
            ).pushReplacement(NoAnimationPageRoute(page: HomePage()));
          } else if (index == 2) {
            Navigator.of(
              context,
            ).pushReplacement(NoAnimationPageRoute(page: ProfilePage()));
          }
        },
      ),
    );
  }
}
