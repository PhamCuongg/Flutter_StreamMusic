import 'package:cloud_firestore/cloud_firestore.dart';

class VideoModel {
  String id = '';
  String author = '';
  String name = '';
  String url = '';
  String image = '';
  bool isDownloaded = false;
  bool isFavorite = false;
  VideoModel({
    required this.id,
    required this.author,
    required this.name,
    required this.url,
    required this.image,
    this.isDownloaded = false,
  });

  VideoModel.fromJson(Map<String, dynamic> json, String iD) {
    id = iD;
    author = json['author'] as String;
    name = json['name'] as String;
    url = json['url'] as String;
    image = json['image'] as String;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['author'] = author;
    data['name'] = name;
    data['url'] = url;
    data['image'] = image;
    return data;
  }

  Future<void> save() async {
    await FirebaseFirestore.instance
        .collection('video')
        .doc(id)
        .update(toJson());
  }
}
