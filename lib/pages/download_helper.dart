import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:CTub/model/video.dart';
import 'package:path_provider/path_provider.dart';

class DownloadHelper {
  factory DownloadHelper({
    Function(double progress)? onProgress,
    VoidCallback? onDownloadComplete,
  }) =>
      _singleton..setCallbacks(onProgress, onDownloadComplete);
  DownloadHelper._();
  static final DownloadHelper _singleton = DownloadHelper._();

  String pathLocal = '';
  Function(double progress)? onProgressCallback;
  VoidCallback? onDownloadCompleteCallback;

  void setCallbacks(
    Function(double progress)? onProgress, VoidCallback? onDownloadComplete) {
    onProgressCallback = onProgress;
    onDownloadCompleteCallback = onDownloadComplete;
  }


  Future<void> init() async {
     pathLocal = await _findLocalPath();
    final dir = Directory(pathLocal);
    if(!dir.existsSync()){
      dir.createSync();
    }
  }

  Future<File?> getFile(String file_name, String id) async {
    final path = '$pathLocal/${id}_$file_name';

 final file = File(path);
    if(!file.existsSync()){
      return null;
    }
          print('get_file_success');
    return file;
  }

  Future<void> downloadFile( VideoModel video ) async {
    final path = '$pathLocal/${video.name}';

    await Dio().download(video.url, path,
    onReceiveProgress: (received, total){
      if(total != -1){
        final progress = (received / total) * 100;
        onProgressCallback?.call(progress);
      }
      });
    }
}


  Future<String> _findLocalPath() async {
      var directory = await getApplicationDocumentsDirectory();
      return directory.path +  '/Download';
  }
