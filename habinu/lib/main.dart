import 'package:flutter/material.dart';
import 'package:habinu/models/data.dart';
import 'package:habinu/models/home.dart';
import 'package:habinu/models/getStarted.dart';

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
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<bool> _hasHabitsFuture;

  @override
  void initState() {
    super.initState();
    _hasHabitsFuture = Future(() => LocalStorage.getTotalHabits() > 0);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasHabitsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink(); // or splash/loading
        }
        if (snapshot.data == true) {
          return HomePage();
        } else {
          return GetStartedPage();
        }
      },
    );
  }
}
