import 'package:flutter/material.dart';
import 'package:habinu/models/navBar.dart';
import 'package:habinu/models/camera.dart';
import 'package:habinu/models/profile.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Page')),
      body: Center(child: Text('Welcome to the Home Page!')),
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
}
