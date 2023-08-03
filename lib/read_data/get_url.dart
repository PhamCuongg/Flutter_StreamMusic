import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:CTub/model/video.dart';
import 'package:CTub/pages/streammusic_page.dart';

class VideoItem {
  final String documentUrl;
  final VideoModel video;

  VideoItem({required this.documentUrl, required this.video});
}

class GetUrl extends StatefulWidget {
  final String documentUrl;
  final VideoModel video;

  GetUrl({required this.documentUrl, required this.video});

  @override
  State<GetUrl> createState() => _GetUrlState();
}

class _GetUrlState extends State<GetUrl> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    CollectionReference video =
        FirebaseFirestore.instance.collection('video');
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: video.doc(widget.documentUrl).get(),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              Map<String, dynamic>? data =
                  snapshot.data!.data() as Map<String, dynamic>?;
              if (data != null && data.containsKey('url')) {
                String url = data['url'];
                return StreamMusic(video: widget.video,);
              }
            }
            return Text('No data available');
          }
          return CircularProgressIndicator();
        }),
      ),
    );
  }
}
