import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:CTub/model/local_db.dart';
import 'package:CTub/model/video.dart';
import 'package:CTub/pages/mymusicDB.dart';
import 'package:objectbox/objectbox.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/subjects.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DownloadV2 {
  String file_path = '';

  void showDownloadSuccessToast() {
    Fluttertoast.showToast(
        msg: "Download Successfully, Added to the Storage Page ",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey,
        textColor: Colors.white);
  }

  factory DownloadV2() => _singleton;
  DownloadV2._();

  static final DownloadV2 _singleton = DownloadV2._();

  Map<String, double> downloaded = {};
  final myMusicDB = MyMusicDB();


  Future<String> _findLocalPath() async {
    print(DateTime.now().toIso8601String());
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    print(DateTime.now().toIso8601String().toString() + directory!.path);
    return directory.path;
  }

  Future<String> getLocalPath(VideoModel file) async {
    file_path = '${await _findLocalPath()}/Download/${file.id}${file.name}';
    return file_path;
  }

  Future<void> downloadFile(VideoModel video, {VoidCallback? onError}) async {
    final streamController = getProgressStreamController(video);

    try {
      if (isDownloading(video.id)) {
        // Downloading
        return;
      }
      final downloadedFile = await getDownloadedFile(video);
      if (downloadedFile != null) {
        return;
      }

      final url = video.url;
      final filePathLocal = await getLocalPath(video);

      await Dio().download(
        url,
        filePathLocal,
        onReceiveProgress: (rec, total) {
          downloaded[video.id] = rec.toDouble();
          // streamController.add(rec.toDouble());
          if (total != -1) {
            print("Rec: $rec, Total: $total");
            final progress = (rec / total);
            streamController.add(progress);
            print(progress);
            // onProgressUpdate(progress);
          }
        },
      );

      

      
      final myMusic = MyMusic(
          name: video.name,
          author: video.author,
          url: video.url,
          image: video.image, objectId: video.id);
      myMusicDB.insetMyMusic(myMusic);
      showDownloadSuccessToast();

      
    } catch (_) {
      downloaded[video.id] = -2;
      streamController.add(-2);
      onError?.call();
    }
  }

  bool isDownloadFailed(String fileId) {
    return downloaded[fileId] != null && downloaded[fileId]! < -1;
  }

  bool isDownloading(String fileId) {
    return downloaded[fileId] != null && downloaded[fileId]! >= 0;
  }

  Future<File?> getDownloadedFile(VideoModel fileContentUDT) async {
    final filePathLocal = await getLocalPath(fileContentUDT);
    final file = File(filePathLocal);
    if (file.existsSync()) {
      return file;
    }
    return null;
  }

  String getDownloadProgressText(double downloaded, double total) {
    var unit = 'B';
    var formated = total;
    var formated2 = downloaded;
    if (formated2 < 0) {
      formated2 = 0;
    }
    final showProgress = formated2 < formated;

    if (formated > 102.4) {
      formated = formated / 1024;
      formated2 = formated2 / 1024;
      unit = 'KB';
    }
    if (formated > 102.4) {
      formated = formated / 1024;
      formated2 = formated2 / 1024;
      unit = 'MB';
    }
    if (formated > 102.4) {
      formated = formated / 1024;
      formated2 = formated2 / 1024;
      unit = 'GB';
    }

    if (showProgress) {
      return '${formated2.toStringAsFixed(2)}/${formated.toStringAsFixed(2)} $unit';
    }
    return '${formated.toStringAsFixed(2)} $unit';
  }

  String convertSizeFile(double total) {
    var unit = 'B';
    var formated = total;

    if (formated > 102.4) {
      formated = formated / 1024;
      unit = 'KB';
    }
    if (formated > 102.4) {
      formated = formated / 1024;
      unit = 'MB';
    }
    if (formated > 102.4) {
      formated = formated / 1024;
      unit = 'GB';
    }
    return '${formated.toStringAsFixed(2)} $unit';
  }

  Map<String, BehaviorSubject<double>> progressStreams = {};

  StreamController<double> getProgressStreamController(VideoModel video) {
    final fileId = video.id;
    var streamController = progressStreams[fileId];

    if (streamController == null) {
      streamController = BehaviorSubject<double>.seeded(0);
      progressStreams[fileId] = streamController;
      getDownloadedFile(video).then((file) {
        if (file != null) {
          streamController!.add(1.0);
        }
      });
    }
    return streamController;
  }

  Stream<double> getProgressStream(VideoModel fileContentUDT) {
    return getProgressStreamController(fileContentUDT).stream;
  }
}
