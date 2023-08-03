import 'package:CTub/pages/videoscreenv2.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:CTub/components/my_textbox.dart';
import 'package:CTub/pages/song_item_widget.dart';
import 'package:CTub/pages/videoscreen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

import 'package:lottie/lottie.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:video_player/video_player.dart';
import '../components/my_textfield.dart';
import 'dart:io';

import '../model/account.dart';
import '../model/video.dart';
import 'home_page.dart';
import 'info_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage>
    with SingleTickerProviderStateMixin {
  AccountModel? accountData;
  String username = '';
  File? selectedImage;
  final currentUser = FirebaseAuth.instance.currentUser;
  final userController = FirebaseFirestore.instance.collection("Users");
  final videoController = FirebaseFirestore.instance.collection("video");
  late TabController _tabController;
    void navigateToInformationPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InfoPage()),
    );
  }
  void playVideo(String videoUrl, String videoId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoScreen(
          videoUrl: videoUrl,
          videoId: videoId,
        ),
      ),
    );
  }

  void playVideov2(String videoUrl, String videoId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoScreenV2(
          videoUrl: videoUrl,
          videoId: videoId,
        ),
      ),
    );
  }

  Future<void> selectImage() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        selectedImage = File(pickedImage.path);
      });
      await uploadProfilePicture(selectedImage!);
    }
  }

  Future<void> uploadProfilePicture(File imageFile) async {
    final fileName = path.basename(imageFile.path);
    final storageRef = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('profileImage/$fileName');
    await storageRef.putFile(imageFile);
    final imageUrl = await storageRef.getDownloadURL();
    await userController
        .doc(currentUser!.email)
        .update({'profileImage': imageUrl});
    updateCommentsUserImage(imageUrl);
  }

  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Edit $field",
          style: const TextStyle(color: Colors.black),
        ),
        content: TextField(
          autofocus: true,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
              hintText: "Enter new $field",
              hintStyle: TextStyle(color: Colors.black)),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(newValue);
              if (field == 'username') {
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser != null) {
                  final userDoc = userController.doc(currentUser.email);
                  await userDoc.update({'username': newValue});

                  updateCommentsUsername(newValue);

                  final updatedUserData = await userDoc.get();
                  setState(() {
                    username = updatedUserData['username'];
                  });
                }
              }
            },
            child: Text('Save', style: TextStyle(color: Colors.black)),
          )
        ],
      ),
    );
  }

  Future<void> updateCommentsUserImage(String newProfileImage) async {
    final commentsSnapshot = await FirebaseFirestore.instance
        .collection('comment')
        .where('userId', isEqualTo: currentUser?.uid)
        .get();

    final batch = FirebaseFirestore.instance.batch();

    for (final commentDoc in commentsSnapshot.docs) {
      batch.update(commentDoc.reference, {
        'profileImage': newProfileImage,
      });
    }

    await batch.commit();
  }

  Future<void> updateCommentsUsername(String newUsername) async {
    final commentsSnapshot = await FirebaseFirestore.instance
        .collection('comment')
        .where('userId', isEqualTo: currentUser?.uid)
        .get();

    final batch = FirebaseFirestore.instance.batch();

    for (final commentDoc in commentsSnapshot.docs) {
      batch.update(commentDoc.reference, {'username': newUsername});
    }

    await batch.commit();
  }

  Future<List<VideoModel>> fetchFavoriteVideos() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final favoritesSnapshot = await FirebaseFirestore.instance
        .collection('user_favorites')
        .doc(currentUser!.uid)
        .collection('favorites')
        .get();

    final favoriteVideoIds =
        favoritesSnapshot.docs.map((doc) => doc['videoId'] as String).toList();

    final List<VideoModel> favoriteVideos = [];

    // Fetch each favorite video from the 'video' collection using the videoIds.
    for (final videoId in favoriteVideoIds) {
      final videoSnapshot = await FirebaseFirestore.instance
          .collection('video')
          .doc(videoId)
          .get();
      if (videoSnapshot.exists) {
        final videoData = videoSnapshot.data() as Map<String, dynamic>;
        final video = VideoModel.fromJson(videoData, videoId);
        favoriteVideos.add(video);
      }
    }

    return favoriteVideos;
  }

  String removeFileExtension(String fileName) {
    final extension = '.mp4';
    if (fileName.endsWith(extension)) {
      return fileName.substring(0, fileName.length - extension.length);
    }
    return fileName;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: StreamBuilder<DocumentSnapshot>(
          stream: userController.doc(currentUser!.email).snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (userSnapshot.hasError) {
              return Center(child: Text('Error: ${userSnapshot.error}'));
            }
            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            accountData = AccountModel.fromJson(userData);

            return StreamBuilder<QuerySnapshot>(
              stream: videoController
                  .where('user_upload', isEqualTo: currentUser!.email)
                  .snapshots(),
              builder: (context, videoSnapshot) {
                if (videoSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (videoSnapshot.hasError) {
                  return Center(child: Text('Error: ${videoSnapshot.error}'));
                }
                final videoDocuments = videoSnapshot.data!.docs;
                print('Video Snapshot: $videoSnapshot');

                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 85,
                            height: 85,
                            child: Lottie.network(
                                'https://lottie.host/ea08129b-ab38-4eab-97c7-9f31b9df0189/sb0B7V8CXb.json'),
                          ),
                          Text(
                            "Account",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
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
                      GestureDetector(
                        onTap: selectImage,
                        child: CircleAvatar(
                          radius: 150,
                          backgroundImage: selectedImage != null
                              ? FileImage(selectedImage!)
                                  as ImageProvider<Object>?
                              : NetworkImage(accountData?.profileImage ?? ''),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        currentUser!.email!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: Text(
                          'My Detail',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      MyTextBox(
                        text: accountData?.username ?? '',
                        sectionName: 'username : ',
                        onPressed: () => editField('username'),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        height: 500,
                        child: DefaultTabController(
                            length: 2, // Number of tabs
                            child: Column(children: [
                              TabBar(
                                controller: _tabController,
                                tabs: [
                                  Tab(
                                    child: Text(
                                      'Playlist Post',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                  Tab(
                                    child: Text(
                                      'Favorite Video',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    // Tab 1
                  
                                    ListView.builder(
                                      itemCount: videoDocuments.length,
                                      itemBuilder: (context, index) {
                                        final videoData = videoDocuments[index]
                                            .data() as Map<String, dynamic>;
                                        final author =
                                            videoData['author'] as String;
                                        final name = removeFileExtension(
                                            videoData['name'] as String);
                                        final image =
                                            videoData['image'] as String;
                                        final videoUrl =
                                            videoData['url'] as String;
                                        final videoId = videoData['id'] as String;
                                        return Column(
                                          children: [
                                            ListTile(
                                              leading: Image.network(
                                                image,
                                                height: 50,
                                                width: 50,
                                              ),
                                              title: Text(name),
                                              subtitle: Text(author),
                                              onTap: () =>
                                                  playVideo(videoUrl, videoId),
                                            ),
                                            Divider(),
                                          ],
                                        );
                                      },
                                    ),
                                    // Tab 2
                                    FutureBuilder<List<VideoModel>>(
                                      future: fetchFavoriteVideos(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                              child: CircularProgressIndicator());
                                        }
                                        if (snapshot.hasError) {
                                          return Center(
                                              child: Text(
                                                  'Error: ${snapshot.error}'));
                                        }
                  
                                        final favoriteVideos = snapshot.data;
                  
                                        if (favoriteVideos == null ||
                                            favoriteVideos.isEmpty) {
                                          return Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width:
                                                      250, // Set the desired width
                                                  height:
                                                      250, // Set the desired height
                                                  child: Lottie.network(
                                                    'https://lottie.host/6560449f-de1f-4536-8712-fea923ee62ab/rbuZhHIdgb.json',
                                                  ),
                                                ),
                                                Text(
                                                  'No favorite video yet',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                  
                                        return ListView.builder(
                                          itemCount: favoriteVideos.length,
                                          itemBuilder: (context, index) {
                                            final video = favoriteVideos[index];
                                            final author = video.author;
                                            final name =
                                                removeFileExtension(video.name);
                                            final image = video.image;
                                            final videoUrl = video.url;
                                            final videoId = video.id;
                  
                                            return Column(
                                              children: [
                                                ListTile(
                                                  leading: Image.network(
                                                    image,
                                                    height: 50,
                                                    width: 50,
                                                  ),
                                                  title: Text(name),
                                                  subtitle: Text(author),
                                                  onTap: () => playVideov2(
                                                      videoUrl, videoId),
                                                ),
                                                Divider(),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ])),
                      ),
                    ]),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
