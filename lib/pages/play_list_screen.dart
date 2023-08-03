import 'package:flutter/material.dart';
import 'package:CTub/model/video.dart';
import 'package:CTub/pages/comment_page.dart';
import 'package:CTub/pages/full_creen.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';

import 'account_page.dart';
import 'download_v2.dart';
import 'song_item_widget.dart';
import 'streammusic_page.dart';

class PlayListScreen extends StatefulWidget {
  final VideoModel initVideo;
  final List<VideoModel> listVideo;

  const PlayListScreen(
      {super.key, required this.initVideo, required this.listVideo});
  @override
  State<StatefulWidget> createState() {
    return PlayListState();
  }
}

class PlayListState extends State<PlayListScreen>
    with SingleTickerProviderStateMixin {
  // final overlayKey = GlobalKey<OverlayState>();
  final videoSelected = Rxn<VideoModel>();
  final _videoPlayerController = Rxn<VideoPlayerController>();
  final helper = DownloadV2();
  late TabController _tabController;
  bool isVideoFavorite(VideoModel video) {
  return widget.initVideo.id == video.id;
}

  @override
  void initState() {
    super.initState();
    videoSelected.value = widget.initVideo;
    _tabController = TabController(length: 2, vsync: this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    init();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (_videoPlayerController.value != null) {
      _videoPlayerController.value!.dispose();
    }
    _tabController.dispose();
    super.dispose();
  }

  init() async {
    try {
      if (_videoPlayerController.value != null) {
        _videoPlayerController.value!.dispose();
      }
      _videoPlayerController.value = null;

      if (videoSelected.value != null) {
        late VideoPlayerController ctr;
        final file = await helper.getDownloadedFile(videoSelected.value!);
        if (file != null && !helper.isDownloading(videoSelected.value!.id)) {
          ctr = VideoPlayerController.file(file);
          ctr.setLooping(true);
        } else {
          ctr = VideoPlayerController.networkUrl(
              Uri.parse(videoSelected.value!.url));
          ctr.setLooping(true);
          // helper.downloadFile(widget.video);
        }
        await ctr.initialize();

        _videoPlayerController.value = ctr;
      }
    } catch (er) {
      final file = await helper.getDownloadedFile(videoSelected.value!);
      if (file != null) {
        await file.delete();
        init();
      }
    }
  }

  void navigateToAccountPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AccountPage()),
    );
  }

  void toggleFullScreen() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Obx(() {
                  return FullScreenPage(
                    video: videoSelected.value!,
                    playNextSong: () {
                      final index = widget.listVideo.indexWhere(
                          (element) => element.id == videoSelected.value!.id);
                      if (index >= 0 && (index + 1) < widget.listVideo.length) {
                        videoSelected.value = widget.listVideo[index + 1];
                        init();
                      }
                    },
                    playPreviousSong: () {
                      final index = widget.listVideo.indexWhere(
                          (element) => element.id == videoSelected.value!.id);
                      if (index >= 1) {
                        videoSelected.value = widget.listVideo[index - 1];
                        init();
                      }
                    },
                    exitFullscreen: () {
                      //  videoSelected.refresh();
                    },
                    controller: _videoPlayerController.value,
                  );
                })));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
          Obx(() {
            if (videoSelected.value == null) {
              return Container();
            }
            return StreamMusic(
              video: videoSelected.value!,
              playNextSong: () {
                final index = widget.listVideo.indexWhere(
                    (element) => element.id == videoSelected.value!.id);
                if (index >= 0 && (index + 1) < widget.listVideo.length) {
                  videoSelected.value = widget.listVideo[index + 1];
                  init();
                }
              },
              playPreviousSong: () {
                final index = widget.listVideo.indexWhere(
                    (element) => element.id == videoSelected.value!.id);
                if (index >= 1) {
                  videoSelected.value = widget.listVideo[index - 1];
                  init();
                }
              },
              toggleFullScreen: () {
                toggleFullScreen();
              },
              controller: _videoPlayerController.value,
            );
          }),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(
                        child: Text(
                          'Playlist',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      Tab(
                        child: Text(
                          'Comment',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Playlist tab content
                        ListView.builder(
                          itemCount: widget.listVideo.length,
                          itemBuilder: (context, index) {
                            final item = widget.listVideo[index];
                            return Obx(() {
                              return SongItemWidget(
                                selected: videoSelected.value == item,
                                onTap: () {
                                  if (videoSelected.value != item) {
                                    videoSelected.value = item;
                                    init();
                                  }
                                },
                                initVideo: item,
                                videos: widget.listVideo,
                              );
                            });
                          },
                        ),
                        // Comment tab content
                        Obx(() {
                            return CommentPage(videoId: videoSelected.value?.id ?? '',);
                          }
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
