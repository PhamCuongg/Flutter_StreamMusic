import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:CTub/model/video.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteController extends GetxController {
  final _favoriteVideos = <VideoModel>[].obs;

  List<VideoModel> get favoriteVideos => _favoriteVideos;

  Future<void> addToFavorites(VideoModel video) async {
    if (!_favoriteVideos.contains(video)) {
      final currentUser = FirebaseAuth.instance.currentUser;
      final videoId = video.id;
      await FirebaseFirestore.instance
          .collection('user_favorites')
          .doc(currentUser!.uid)
          .collection('favorites')
          .doc(videoId)
          .set({'videoId': videoId, 'userId': currentUser.uid});

      _favoriteVideos.add(video);
      update();
    }
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

    _favoriteVideos.removeWhere((v) => v.id == video.id);
    update();
  }

  bool isVideoFavorite(VideoModel video) {
    return _favoriteVideos.contains(video);
  }
}
