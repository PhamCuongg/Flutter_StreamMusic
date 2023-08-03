import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:CTub/pages/auth_page.dart';
import 'firebase_options.dart';
import 'objectbox.dart';
import 'pages/mymusicDB.dart';

late ObjectBox objectbox;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  objectbox = await ObjectBox.create();
  MyMusicDB().init(objectbox);
  // ignore: prefer_const_constructors
  runApp(Home());
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
    );
  }
}