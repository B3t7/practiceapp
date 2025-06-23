import 'package:flutter/material.dart';
import 'package:practiceapp/pages/tests/math/mathtest1.dart';
import 'package:practiceapp/pages/tests/pyhsics/physicstest1.dart';
import 'package:practiceapp/pages/colors.dart';
import 'package:practiceapp/pages/mainpages/profile.dart';
import 'package:practiceapp/auth/signup_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:practiceapp/auth/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/mathtest1': (context) => const Mathtest1(),
        '/pyhsicstest1': (context) => const Physicstest1(),
        '/profile': (context) => const ProfilePage(),
        '/home': (context) => const HomeScreen(),
        '/signup': (context) => const RegisterPage(),
      },

      title: 'Quiz App',
      theme: ThemeData(
        fontFamily: 'Arial', // Google Fonts sonra ekleyebiliriz
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.pushNamed(context, '/profile').then((_) {
        setState(() {
          _selectedIndex = 0; // Reset to Home after returning
        });
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  final username = authService.value.currentUser?.displayName ?? 'Guest';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offwhite,
      appBar: AppBar(
        backgroundColor: lightp,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "Good morning, $username",
            style: TextStyle(color: offwhite),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: CircleAvatar(
              backgroundColor: mint,
              child: Icon(Icons.person, color: lightp),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18.0),
        children: [
          _buildQuizCard(),
          const SizedBox(height: 16),
          _buildFeaturedCard(),
          const SizedBox(height: 16),
          Text("Live Quizzes", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildQuizMath(context),
          _buildQuizPyhsics(context),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: lightp,
        selectedItemColor: mint,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmarks',
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard() {
    return Card(
      color: Colors.purple[100],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: const [
            Icon(Icons.music_note, size: 48, color: Colors.white),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                "A Basic Music Quiz\n96%",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard() {
    return Card(
      color: Colors.deepPurple,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            Text(
              "Take part in challenges\nwith friends or other players",
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            ElevatedButton(onPressed: null, child: Text("Find Friends")),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizMath(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.quiz, color: Colors.deepPurple),
      title: Text("Math", style: TextStyle(fontSize: 18)),
      subtitle: Text("20 questions"),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.pushNamed(context, '/mathtest1');
      },
    );
  }

  Widget _buildQuizPyhsics(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.quiz, color: Colors.deepPurple),
      title: Text("Physics", style: TextStyle(fontSize: 18)),
      subtitle: Text("20 questions"),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.pushNamed(context, '/pyhsicstest1');
      },
    );
  }
}
