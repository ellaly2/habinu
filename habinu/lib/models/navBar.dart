import 'package:flutter/material.dart';

/// Custom PageRoute that disables animations
class NoAnimationPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  NoAnimationPageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      );
}

/// Reusable BottomNavigationBar widget
class NavBar extends StatelessWidget {
  final int pageIndex;
  final Function(int) onTap;

  const NavBar({super.key, required this.pageIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(height: 1, color: Colors.grey[400]),
        Container(
          padding: const EdgeInsets.only(top: 20),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 50),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt, size: 50),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, size: 50),
                label: '',
              ),
            ],
            currentIndex: pageIndex,
            selectedItemColor: Colors.amber[800],
            onTap: onTap,
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
        ),
      ],
    );
  }
}
