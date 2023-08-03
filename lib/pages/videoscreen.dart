import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  final String videoUrl;
  final String videoId;
  const VideoScreen({super.key, required this.videoUrl, required this.videoId});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  String id = '';
  String name = '';
  String author = '';
  String userUpload = '';
  

  String removeFileExtension(String fileName) {
    final extension = '.mp4';
    if (fileName.endsWith(extension)) {
      return fileName.substring(0, fileName.length - extension.length);
    }
    return fileName;
  }

  Future<void> _fetchVideoInfo() async {
    final videoDocSnapshot = await FirebaseFirestore.instance
        .collection('video')
        .where('id', isEqualTo: widget.videoId)
        .get();

    if (videoDocSnapshot.docs.isNotEmpty) {
      final videoData = videoDocSnapshot.docs.first.data() as Map<String, dynamic>;
      setState(() {
        name = removeFileExtension(videoData['name']);
        author = videoData['author'];
        userUpload = videoData['user_upload'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      autoInitialize: true,
      showControls: true,
    );
    _fetchVideoInfo();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Text(
                  "Playlist",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Container(
                  width: 85, // Set the desired width
                  height: 85, // Set the desired height
                  child: Lottie.network(
                      'https://lottie.host/ea08129b-ab38-4eab-97c7-9f31b9df0189/sb0B7V8CXb.json'),
                ), //Logout
              ],
            ),
            Container(
              height: 250,
              child: Chewie(controller: _chewieController),
            ),
            Column(
              children: [
                SizedBox(height: 10,),
                Text('$name', style: TextStyle(fontSize: 25,),),
                SizedBox(height: 10,),
                Text('$author', style: TextStyle(fontSize: 20, color: Colors.grey.shade500),),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
