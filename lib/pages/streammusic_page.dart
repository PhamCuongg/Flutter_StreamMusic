import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:CTub/controller/home_controller.dart';
import 'package:CTub/model/video.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'download_v2.dart';

class StreamMusic extends StatefulWidget {
  final VideoModel video;

  final Function()? playPreviousSong;
  final Function()? playNextSong;
  final Function()? toggleFullScreen;
  final VideoPlayerController? controller;

  const StreamMusic(
      {super.key,
      required this.video,
      this.playPreviousSong,
      this.playNextSong,
      this.toggleFullScreen,
      this.controller});

  @override
  State<StreamMusic> createState() => _StreamMusicState();
}

class _StreamMusicState extends State<StreamMusic> {
  bool _controlsVisible = true;
  final helper = DownloadV2();
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isSliderDragging = false;
  void playNextSong() {
    if (widget.playNextSong != null) {
      widget.playNextSong!();
    }
  }

  void playPreviousSong() {
    if (widget.playPreviousSong != null) {
      widget.playPreviousSong!();
    }
  }

  void toggleFullScreen() {
    if (widget.toggleFullScreen != null) {
      widget.toggleFullScreen!();
    }
  }

  void _showDownloadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Download"),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Do you want to download?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                },
                child: Text("No")),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                helper.downloadFile(widget.video);
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  double _getSliderProgressValue() {
    if (_totalDuration.inMilliseconds > 0) {
      return _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
    } else {
      return 0.0;
    }
  }

  void _onSliderDragStart() {
    setState(() {
      _isSliderDragging = true;
    });
  }

  void _onSliderDragEnd() {
    setState(() {
      _isSliderDragging = false;
    });
  }

  void _onSliderChanged(double value) {
    final newPosition = Duration(seconds: (value * _totalDuration.inSeconds).round());
    widget.controller?.seekTo(newPosition);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _controlsVisible = !_controlsVisible;
        });
      },
      child: Container(
          height: 250,
          child: widget.controller != null
              ? AspectRatio(
                  aspectRatio: widget.controller!.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      VideoPlayer(widget.controller!),
                      Visibility(
                        visible: _controlsVisible && widget.controller !=null,
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // IconButton(
                                  //     onPressed: () {
                                  //       final newPosition = _currentPosition -
                                  //           Duration(seconds: 10);
                                  //       widget.controller!.seekTo(newPosition);
                                  //     },
                                  //     icon: Icon(Icons.replay_10),
                                  //     color: Colors.grey.shade200,
                                  //   ),
                                  IconButton(
                                    onPressed: playPreviousSong,
                                    icon: Icon(Icons.skip_previous),
                                    color: Colors.grey.shade200,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        if (widget.controller!.value.isPlaying) {
                                          widget.controller!.pause();
                                        } else {
                                          widget.controller!.play();
                                        }
                                      });
                                    },
                                    icon: Icon(widget.controller!.value.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow),
                                    color: Colors.grey.shade200,
                                  ),
                                  IconButton(
                                    onPressed: playNextSong,
                                    icon: Icon(Icons.skip_next),
                                    color: Colors.grey.shade200,
                                  ),
                                  // IconButton(
                                  //     onPressed: () {
                                  //       final newPosition = _currentPosition +
                                  //           Duration(seconds: 10);
                                  //       widget.controller!.seekTo(newPosition);
                                  //     },
                                  //     icon: Icon(Icons.forward_10),
                                  //     color: Colors.grey.shade200,
                                  //   ),
                                  IconButton(
                                    onPressed: toggleFullScreen,
                                    icon: Icon(Icons.fullscreen),
                                    color: Colors.grey.shade200,
                                  ),
                                ],
                              ),
                            //   SliderTheme(
                            //   data: SliderThemeData(
                            //     thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
                            //     overlayShape: RoundSliderOverlayShape(overlayRadius: 16.0),
                            //     thumbColor: Colors.white,
                            //     overlayColor: Colors.white.withAlpha(100),
                            //     activeTrackColor: Colors.white,
                            //     inactiveTrackColor: Colors.grey.shade300,
                            //   ),
                            //   child: Slider(
                            //     value: _isSliderDragging ? _getSliderProgressValue() : 0.0,
                            //     onChanged: _isSliderDragging ? _onSliderChanged : null,
                            //     onChangeStart: (value) => _onSliderDragStart(),
                            //     onChangeEnd: (value) => _onSliderDragEnd(),
                            //   ),
                            // ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: StreamBuilder<double>(
                            stream: helper.getProgressStream(widget.video),
                            builder: (context, snapshot) {
                              final downloadProgress = snapshot.hasData
                                  ? ((snapshot.data! * 100).toStringAsFixed(0) +
                                      '%')
                                  : '';
                              return snapshot.data == 1.0
                                  ? Container()
                                  : Visibility(
                                    visible: _controlsVisible,
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            downloadProgress,
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              _showDownloadDialog(context);
                                            },
                                            icon: Icon(Icons.download),
                                            color: Colors.grey.shade200,
                                          ),
                                        ],
                                      ),
                                  );
                            }),
                      ),
                    ],
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                )),
    );
  }
}
