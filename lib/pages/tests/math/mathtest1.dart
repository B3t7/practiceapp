import 'package:flutter/material.dart';
import 'package:practiceapp/pages/colors.dart';

class Mathtest1 extends StatelessWidget {
  const Mathtest1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offwhite, // offwhite color
      appBar: AppBar(title: const Text('Test 1 Page')),
      body: const Center(
        child: Text('This is a math test.', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
