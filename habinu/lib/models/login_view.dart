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

  // 1. Updated Client ID based on your provided information
  static const String auth0Domain = 'dev-tay00lhd2iir2f30.us.auth0.com';
  static const String auth0ClientId = 'v3Hc8YNsjMyOCb3v2OZtoGDpMbG9Yu1b'; // <-- UPDATED
  
  // 2. Define the custom scheme used for the mobile app redirect.
  static const String customScheme = 'habinu'; // MUST MATCH Gradle/Info.plist

  @override
  void initState() {
    super.initState();
    // Use the standardized domain
    auth0 = Auth0(auth0Domain, auth0ClientId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Added an AppBar to make the screen title immediately visible
      appBar: AppBar(
        title: const Text('Habinu Habit Tracker'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: _credentials == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome to Habinu! Please log in to continue.',
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        // 3. Pass the custom scheme to webAuthentication().
                        final credentials = await auth0.webAuthentication(scheme: customScheme).login();

                        setState(() {
                          _credentials = credentials;
                        });

                        // After successful login, go to CreateFirstHabit
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => CreateFirstHabit(),
                          ),
                        );
                      } catch (e) {
                        // This catch block handles the 'authentication_canceled' error (browser closed)
                        debugPrint('Login error: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Login failed, please try again. Check console logs for Auth0 configuration errors.')),
                        );
                      }
                    },
                    child: const Text("Log in"),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '(If login fails, check your Auth0 Callback URLs!)',
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ProfileView(user: _credentials!.user),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // Also use the custom scheme for logout
                      await auth0.webAuthentication(scheme: customScheme).logout();
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
