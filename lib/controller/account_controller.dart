import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../model/video.dart';

class AccountController extends GetxController{
  final docs = <VideoModel>[].obs;
    Future getVidId() async {
    docs.clear();
    final snapshot =  await FirebaseFirestore.instance.collection("video").where('user_upload').get();

    final listData =  snapshot.docs.map((e) => VideoModel.fromJson(e.data(), e.reference.id)).toList();
    docs.value =listData;
    docs.refresh();
  }
}