import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetSongName extends StatelessWidget {

  final String name;

  GetSongName({required this.name});

  @override
  Widget build(BuildContext context) {
    CollectionReference video = FirebaseFirestore.instance.collection('video');

    return Text(name);
  }
}