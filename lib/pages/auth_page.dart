import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:CTub/auth/loign_or_register.dart';
import 'package:CTub/pages/master_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            return MasterPage();
          } else {
            return LoginOrRegister();
          }
        },
      ),
    );
  }
}