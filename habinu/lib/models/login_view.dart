import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'profile_view.dart';
import 'createFirstHabit.dart'; // 👈 import your next page

class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  Credentials? _credentials;
  late Auth0 auth0;

  @override
  void initState() {
    super.initState();
    auth0 = Auth0('auth0-dsepaid.auth0.com', 'OywWcFnHsbz50TfbRLWK0YTzrpxkwQL5');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _credentials == null
            ? ElevatedButton(
                onPressed: () async {
                  try {
                    final credentials =
                        await auth0.webAuthentication().login(useHTTPS: true);

                    setState(() {
                      _credentials = credentials;
                    });

                    // 👇 After successful login, go to CreateFirstHabit
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => CreateFirstHabit(),
                      ),
                    );
                  } catch (e) {
                    debugPrint('Login error: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Login failed, please try again')),
                    );
                  }
                },
                child: const Text("Log in"),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ProfileView(user: _credentials!.user),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await auth0.webAuthentication().logout(useHTTPS: true);
                      setState(() {
                        _credentials = null;
                      });
                    },
                    child: const Text("Log out"),
                  ),
                ],
              ),
      ),
    );
  }
}
