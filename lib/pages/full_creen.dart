import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:CTub/model/video.dart';
import 'package:CTub/pages/download_v2.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class FullScreenPage extends StatefulWidget {
  final VideoModel video;
  final Function() playNextSong;
  final Function() playPreviousSong;
  final Function() exitFullscreen;
  final VideoPlayerController? controller;

  const FullScreenPage({
    required this.video,
    required this.playNextSong,
    required this.playPreviousSong,
    required this.exitFullscreen,
    this.controller,
  });

  @override
  _FullScreenPageState createState() => _FullScreenPageState();
}

class _FullScreenPageState extends State<FullScreenPage> {
  String downloadProgress = '';
  final helper = DownloadV2();
  bool _controlsVisible = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;


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

  void playNextSong() {
    if (widget.playNextSong != null) {
      widget.playNextSong();
    }
  }

  void playPreviousSong() {
    if (widget.playPreviousSong != null) {
      widget.playPreviousSong();
    }
  }
  // VideoPlayerController? _videoPlayerController;
  // Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // _videoPlayerController?.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    widget.exitFullscreen();
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
      child: Scaffold(
        body: widget.controller == null
            ? const SafeArea(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : OrientationBuilder(
                builder: (context, orientation) {
                  bool isLandscape = orientation == Orientation.landscape;
                  return AspectRatio(
                    aspectRatio: isLandscape
                        ? MediaQuery.of(context).size.aspectRatio
                        : widget.controller!.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        VideoPlayer(widget.controller!),
                        Visibility(
                          visible:
                              _controlsVisible && widget.controller != null,
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // IconButton(
                                    //   onPressed: () {
                                    //     final newPosition = _currentPosition -
                                    //         Duration(seconds: 10);
                                    //     widget.controller!.seekTo(newPosition);
                                    //   },
                                    //   icon: Icon(Icons.replay_10),
                                    //   color: Colors.grey.shade200,
                                    // ),
                                    IconButton(
                                      onPressed: playPreviousSong,
                                      icon: Icon(Icons.skip_previous),
                                      color: Colors.grey.shade200,
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          if (widget
                                              .controller!.value.isPlaying) {
                                            widget.controller!.pause();
                                          } else {
                                            widget.controller!.play();
                                          }
                                        });
                                      },
                                      icon: Icon(
                                          widget.controller!.value.isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow),
                                      color: Colors.grey.shade200,
                                    ),
                                    IconButton(
                                      onPressed: playNextSong,
                                      icon: Icon(Icons.skip_next),
                                      color: Colors.grey.shade200,
                                    ),
                                    // Nút tua tới 10s
                                    // IconButton(
                                    //   onPressed: () {
                                    //     final newPosition = _currentPosition +
                                    //         Duration(seconds: 10);
                                    //     widget.controller!.seekTo(newPosition);
                                    //   },
                                    //   icon: Icon(Icons.forward_10),
                                    //   color: Colors.grey.shade200,
                                    // ),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: Icon(Icons.fullscreen_exit),
                                      color: Colors.grey.shade200,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Visibility(
                            visible: _controlsVisible,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                StreamBuilder<double>(
                                  stream:
                                      helper.getProgressStream(widget.video),
                                  builder: (context, snapshot) {
                                    final downloadProgress = snapshot.hasData
                                        ? ((snapshot.data! * 100)
                                                .toStringAsFixed(0) +
                                            '%')
                                        : '';

                                    return Text(
                                      downloadProgress,
                                      style: TextStyle(color: Colors.white),
                                    );
                                  },
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
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
