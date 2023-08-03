import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ButtonWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onClicked;

  const ButtonWidget({super.key, required this.icon, required this.text, required this.onClicked});

  @override
  Widget build(BuildContext context) => ElevatedButton(
    style: ElevatedButton.styleFrom(
      primary: Color.fromRGBO(0, 0, 0, 1),
      minimumSize: Size.fromHeight(50),
    ),
    child: buildContent(),
    onPressed: onClicked,
  );

  Widget buildContent() => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 28,),
      SizedBox(width: 16,),
      Text(text,style: TextStyle(fontSize: 22, color: Colors.white),)
    ],
  );
}