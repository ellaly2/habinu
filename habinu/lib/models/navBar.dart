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
  final bool hasNotifications;

  const NavBar({super.key, required this.pageIndex, required this.onTap, this.hasNotifications = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(height: 1, color: Color(0xffCBD0D3)),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(top: 20),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Image.asset(
                  pageIndex == 0
                      ? 'lib/assets/home-active.png'
                      : 'lib/assets/home.png',
                  width: 50,
                  height: 50,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  pageIndex == 1
                      ? 'lib/assets/search-active.png'
                      : 'lib/assets/search.png',
                  width: 50,
                  height: 50,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  pageIndex == 2
                      ? 'lib/assets/camera-active.png'
                      : 'lib/assets/camera.png',
                  width: 50,
                  height: 50,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  pageIndex == 3
                      ? 'lib/assets/list-active.png'
                      : hasNotifications 
                          ? 'lib/assets/notifications.png'
                          : 'lib/assets/list.png',
                  width: 50,
                  height: 50,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: pageIndex == 4
                          ? Color(0xfffbb86a)
                          : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(25), // Made it circular
                  ),
                  padding: pageIndex == 4 ? const EdgeInsets.all(2) : null,
                  child: Image.asset(
                    'lib/assets/panda-profile.png',
                    width: pageIndex == 4 ? 46 : 50,
                    height: pageIndex == 4 ? 46 : 50,
                  ),
                ),
                label: '',
              ),
            ],
            currentIndex: pageIndex,
            selectedItemColor: Color(0xfffbb86a),
            onTap: onTap,
            elevation: 0,
          ),
        ),
      ],
    );
  }
}
