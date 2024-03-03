import 'package:datingapp/Widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Dating App",
          style: TextStyle(
            fontFamily: "MadimiOne",
            fontSize: 30,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: NavigationExample(),
    );
  }
}
