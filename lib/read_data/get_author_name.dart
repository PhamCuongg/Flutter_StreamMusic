import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetAuthorName extends StatelessWidget {

  final String documentAuthor;

  GetAuthorName({required this.documentAuthor});

  @override
  Widget build(BuildContext context) {
    CollectionReference video = FirebaseFirestore.instance.collection('video');

    return FutureBuilder<DocumentSnapshot>(
      future: video.doc(documentAuthor).get(),
      builder: ((context, snapshot){
      if(snapshot.connectionState == ConnectionState.done){
        Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
        return Text('${data['author']}');
      }
      return Container();
    }
    ),
    );
  }
}