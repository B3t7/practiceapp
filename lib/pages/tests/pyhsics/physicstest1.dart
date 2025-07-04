import 'package:flutter/material.dart';
import 'package:practiceapp/pages/colors.dart';

class Physicstest1 extends StatelessWidget {
  const Physicstest1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offwhite,
      appBar: AppBar(title: const Text('Test 1 Page')),
      body: const Center(
        child: Text('This is a pyhsics test.', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
