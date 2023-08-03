import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:CTub/components/my_button.dart';
import 'package:CTub/components/my_textfield.dart';
import 'package:CTub/components/square_tile.dart';
import 'package:lottie/lottie.dart';

import 'forgot_pw.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  LoginPage({super.key, required this.onTap});

  static const IconData library_music =
      IconData(0xe378, fontFamily: 'MaterialIcons');

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  void signUserIn() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      //pop loading circle
      if (context.mounted) Navigator.pop(context);
      //show error to user
      displayMessage(e.code);
    }
  }
  void displayMessage(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(message),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(height: 20),
            Container(
              width: 150, // Set the desired width
              height: 150, // Set the desired height
              child: Lottie.network(
                  'https://lottie.host/ea08129b-ab38-4eab-97c7-9f31b9df0189/sb0B7V8CXb.json'),
            ),
            SizedBox(height: 20),
            Text(
              'Welcome back you\'ve been missed',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
              ),
            ),
            SizedBox(height: 25),
            MyTextField(
              controller: emailController,
              hintText: 'Email',
              obscureText: false,
            ),
            SizedBox(height: 25),
            MyTextField(
              controller: passwordController,
              hintText: 'Password',
              obscureText: true,
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ForgotPasswordPage();
                          },
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            MyButton(
              onTap: signUserIn,
              text: 'Sign In',
            ),
            SizedBox(
              height: 20,
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 25.0),
            //   child:
            //   Row(
            //     children: [
            //       Expanded(
            //         child: Divider(
            //           thickness: 0.5,
            //           color: Colors.grey[400],
            //         ),
            //       ),
            //       Padding(
            //         padding: EdgeInsets.symmetric(horizontal: 25.0),
            //         child: Text(
            //           'Or continue with',
            //           style: TextStyle(color: Colors.grey[700]),
            //         ),
            //       ),
            //       Expanded(
            //         child: Divider(
            //           thickness: 0.5,
            //           color: Colors.grey[400],
            //         ),
            //       )
            //     ],
            //   ),
            // ),
            // SizedBox(
            //   height: 25,
            // ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     SquareTile(imagePath: 'lib/images/google.png'),
            //   ],
            // ),
            SizedBox(
              height: 35,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Not a member?',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                SizedBox(
                  width: 4,
                ),
                GestureDetector(
                  onTap: widget.onTap,
                  child: Text(
                    'Register now',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            )
          ]),
        ),
      ),
    );
  }
}
