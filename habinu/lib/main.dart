import 'package:flutter/material.dart';
import 'package:habinu/models/data.dart';
import 'package:habinu/models/home.dart';
import 'package:habinu/models/data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // required for async init
  await LocalStorage.init(); // initialize shared_preferences
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return HomePage(); // no changes here
  }
}
