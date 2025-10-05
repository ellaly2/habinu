import 'package:flutter/material.dart';
import 'package:habinu/models/createFirstHabit.dart';
import 'package:habinu/models/login_view.dart'; // 👈 import MainView

class GetStartedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Habinu',
              style: TextStyle(
                fontSize: 65,
                fontWeight: FontWeight.bold,
                color: Color(0xfffbb86a),
              ),
            ),
            Image.asset(
              'lib/assets/dog-check.png',
              height: 250,
              width: 250,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const MainView()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xfffbb86a),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                shadowColor: Colors.transparent,
              ),
              child: Container(
                alignment: Alignment.center,
                height: 50,
                width: 300,
                child: Text(
                  "Get Started",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xffffddb7),
    );
  }
}
