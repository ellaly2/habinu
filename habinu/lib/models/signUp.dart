import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignUpState extends StatefulWidget {
  const SignUpState({super.key});

  @override
  State<SignUpState> createState() => SignUp();
}

class SignUp extends State<SignUpState> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> signUp() async {
    final url = Uri.parse("http://172.16.226.154:3000/");
    try {
      final response = await http.post(
        url,
        headers: <String, String> {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String> {
          "username": usernameController.text,
          "password": passwordController.text
        }));
      debugPrint(response.body);
      if (response.statusCode == 201) { // 201 Created for successful POST
        debugPrint('Data posted successfully: ${response.body}');
      } else {
        debugPrint('Failed to post data with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        TextField(
          controller: usernameController,
          decoration: InputDecoration(
            labelText: "Username",
          ),
        ),
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: "Password",
          ),
        ),
        ElevatedButton(onPressed: signUp, child: Text("Sign Up")),
      ],)
    );
  }
}