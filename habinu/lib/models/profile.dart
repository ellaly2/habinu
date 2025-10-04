import 'package:flutter/material.dart';
import 'package:habinu/models/navBar.dart';
import 'package:habinu/models/home.dart';
import 'package:habinu/models/camera.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile Page')),
      body: Center(child: Text('Welcome to the Profile Page!')),
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
}
