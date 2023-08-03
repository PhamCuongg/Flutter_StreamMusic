import 'package:CTub/pages/info_page.dart';
import 'package:flutter/material.dart';
import 'package:CTub/controller/home_controller.dart';
import 'package:CTub/model/local_db.dart';
import 'package:CTub/pages/mymusicDB.dart';
import 'package:CTub/pages/song_item_widget.dart';
import 'package:lottie/lottie.dart';

import '../model/video.dart';
import 'account_page.dart';
import 'download_v2.dart';
import 'home_page.dart';

class StoragePage extends StatefulWidget {
  const StoragePage({super.key});

  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  final DownloadV2 downloadManager = DownloadV2();
  final homeController = HomeController();
  List<MyMusic> downloadedVideos = [];
  final myMusicDB = MyMusicDB();
  bool isSearching = false;
  VideoModel? selectedVideo;
  bool isDownloaded = false;
  bool hasDownloadedVideos = false;

  void navigateToInformationPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InfoPage()),
    );
  }

  void loadDownloadedVideos() {
    downloadedVideos = myMusicDB.getALlMusic();
    hasDownloadedVideos = downloadedVideos.isNotEmpty;
    setState(() {});
  }

  void onVideoSelected(VideoModel video) {
    setState(() {
      selectedVideo = video;
    });
  }

  void updateDownloadStatus() async {
    if (selectedVideo != null) {
      final file = await downloadManager.getDownloadedFile(selectedVideo!);
      setState(() {
        selectedVideo!.isDownloaded = file != null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadDownloadedVideos();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //Hi...
                      Container(
                        width: 85, // Set the desired width
                        height: 85, // Set the desired height
                        child: Lottie.network(
                            'https://lottie.host/ea08129b-ab38-4eab-97c7-9f31b9df0189/sb0B7V8CXb.json'),
                      ),
                      Text(
                        "Storage",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      //Logout
                      Container(
                        child: PopupMenuButton<String>(
                          icon: Icon(
                            Icons.menu,
                            size: 35.0,
                            color: Colors.black,
                          ),
                          onSelected: (value) {
                            if (value == 'logout') {
                              signUserOut();
                            } else if (value == 'info') {
                              navigateToInformationPage(context);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem<String>(
                              value: 'info',
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline),
                                  SizedBox(width: 10.0),
                                  Text('Info'),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'logout',
                              child: Row(
                                children: [
                                  Icon(Icons.logout),
                                  SizedBox(width: 10.0),
                                  Text('Log out'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 25,
                  ),
                ],
              ),
            ),
            Expanded(
              child: hasDownloadedVideos
                  ? ListView.builder(
                      itemCount: downloadedVideos.length,
                      itemBuilder: (context, index) {
                        final video = downloadedVideos[index];
                        return SongItemWidget(
                          initVideo: VideoModel(
                            id: video.objectId.toString(),
                            name: video.name,
                            author: video.author,
                            url: video.url,
                            image: video.image,
                            isDownloaded:
                                selectedVideo?.id == video.objectId.toString(),
                          ),
                          videos: downloadedVideos.map((myMusic) {
                            return VideoModel(
                              id: myMusic.objectId.toString(),
                              author: myMusic.author,
                              name: myMusic.name,
                              url: myMusic.url,
                              image: myMusic.image,
                              isDownloaded: selectedVideo?.id ==
                                  myMusic.objectId.toString(),
                            );
                          }).toList(),
                        );
                      },
                    )
                  : Center(
                      child: Column(children: [
                        Container(
                          width: 250, // Set the desired width
                          height: 250, // Set the desired height
                          child: Lottie.network(
                              'https://lottie.host/2ff2c5df-d462-4889-8f47-11122de51120/M4XmX32Yk9.json'),
                        ),
                        SizedBox(height: 50,),
                        Text('No video has been downloaded'),
                      ]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
