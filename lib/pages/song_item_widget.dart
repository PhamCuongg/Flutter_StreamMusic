import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:CTub/model/video.dart';
import 'package:CTub/pages/play_list_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../read_data/get_photo.dart';

class SongItemWidget extends StatefulWidget {
  final Function(VideoModel video)? onFavorite;
  
  String removeFileExtension(String fileName) {
    final extension = '.mp4';
    if (fileName.endsWith(extension)) {
      return fileName.substring(0, fileName.length - extension.length);
    }
    return fileName;
  }

  final VideoModel initVideo;
  final List<VideoModel> videos;
  final Function()? onTap;
  final bool selected;

  Future<void> addToFavorites(VideoModel video) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final videoId = video.id;
    await FirebaseFirestore.instance
        .collection('user_favorites')
        .doc(currentUser!.uid)
        .collection('favorites')
        .doc(videoId)
        .set({'videoId': videoId, 'userId': currentUser.uid});

    Fluttertoast.showToast(msg: 'Added to favorites');
  }

  Future<void> removeFromFavorites(VideoModel video) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final videoId = video.id;
  
    await FirebaseFirestore.instance
        .collection('user_favorites')
        .doc(currentUser!.uid)
        .collection('favorites')
        .doc(videoId)
        .delete();

    Fluttertoast.showToast(msg: 'Removed from favorites');
  }
  

  const SongItemWidget({
    Key? key,
    required this.initVideo,
    required this.videos,
    this.onTap,
    this.selected = false,
    this.onFavorite,
  }) : super(key: key);

  @override
  _SongItemWidgetState createState() => _SongItemWidgetState();
}

class _SongItemWidgetState extends State<SongItemWidget>{
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    checkIsFavorite();
  }

  Future<void> checkIsFavorite() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final videoId = widget.initVideo.id;
    final snap = await FirebaseFirestore.instance
        .collection('user_favorites')
        .doc(currentUser!.uid)
        .collection('favorites')
        .doc(videoId)
        .get();

    if (mounted) {
    setState(() {
      isFavorite = snap.exists;
    });
  }
  }

  
  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
    if (isFavorite) {
      widget.addToFavorites(widget.initVideo);
    } else {
      widget.removeFromFavorites(widget.initVideo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoName = widget.removeFileExtension(widget.initVideo.name);
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: widget.selected ? Colors.grey[300] : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1.0,
          ),
        ),
      ),
      child: InkWell(
        onTap: widget.onTap ??
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlayListScreen(
                    initVideo: widget.initVideo,
                    listVideo: widget.videos,
                  ),
                ),
              );
            },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GetPhoto(
                imageUrl: widget.initVideo.image,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      videoName,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.initVideo.author,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _toggleFavorite,
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
              )
            ],
          ),
        ),
      ),
    );
  }
  
}
