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
        Container(height: 1, color: Color(0xffCBD0D3)),
        Container(
          padding: const EdgeInsets.only(top: 20),
          child: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Image.asset(
                  pageIndex == 0 ? 'lib/assets/home-active.png' : 'lib/assets/home.png',
                  width: 50,
                  height: 50,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  pageIndex == 1 ? 'lib/assets/camera-active.png' : 'lib/assets/camera.png',
                  width: 50,
                  height: 50,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  pageIndex == 2 ? 'lib/assets/profile-active.png' : 'lib/assets/profile.png',
                  width: 50,
                  height: 50,
                ),
                label: '',
              ),
            ],
            currentIndex: pageIndex,
            selectedItemColor: Color(0xfffbb86a),
            onTap: onTap,
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
        ),
      ],
    );
  }
}
