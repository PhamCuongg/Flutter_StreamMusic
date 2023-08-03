// import 'package:CTub/pages/play_list_screen.dart';
// import 'package:CTub/pages/song_item_widget.dart';
// import 'package:chewie/chewie.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:lottie/lottie.dart';
// import 'package:video_player/video_player.dart';
// import '../model/video.dart';
// import '../read_data/get_photo.dart';
// import 'account_page.dart';
// import 'home_page.dart';

// class FavoritePage extends StatefulWidget {
//   const FavoritePage({
//     Key? key,
//   }) : super(key: key);

//   @override
//   _FavoritePageState createState() => _FavoritePageState();
// }

// class _FavoritePageState extends State<FavoritePage> {
//   List<VideoModel> favoriteVideos = [];
//   late final Function(VideoModel)? onTap;

//   String removeFileExtension(String fileName) {
//     final extension = '.mp4';
//     if (fileName.endsWith(extension)) {
//       return fileName.substring(0, fileName.length - extension.length);
//     }
//     return fileName;
//   }

//   void showToast(String message) {
//     Fluttertoast.showToast(
//       msg: message,
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       timeInSecForIosWeb: 1,
//       backgroundColor: Colors.black,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//   }


//   void navigateToAccountPage(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => AccountPage()),
//     );
//   }

//   Future<void> fetchFavoriteVideos() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         final favoritesSnapshot = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .collection('favorites')
//             .get();

//         final favoriteVideoIds =
//             favoritesSnapshot.docs.map((doc) => doc['videoId']).toList();

//         // Fetch details of favorite videos from the 'video' collection
//         final favoriteVideosSnapshot = await FirebaseFirestore.instance
//             .collection('video')
//             .where(FieldPath.documentId, whereIn: favoriteVideoIds)
//             .get();

//         final favoriteVideosData =
//             favoriteVideosSnapshot.docs.map((doc) => doc.data()).toList();

//         // Convert favoriteVideosData to List<VideoModel>
//         List<VideoModel> favoriteVideosList = favoriteVideosData
//             .map((videoData) => VideoModel.fromJson(videoData, videoData['id']))
//             .toList();

//         setState(() {
//           favoriteVideos = favoriteVideosList;
//         });
//       }
//     } catch (e) {
//       showToast('Error fetching favorite videos: $e');
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     fetchFavoriteVideos();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 25.0),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       //Hi...
//                       Container(
//                         width: 85,
//                         height: 85,
//                         child: Lottie.network(
//                           'https://lottie.host/ea08129b-ab38-4eab-97c7-9f31b9df0189/sb0B7V8CXb.json',
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       Text(
//                         "Favorite",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 20,
//                         ),
//                       ),
//                       //Logout
//                       Container(
//                         child: PopupMenuButton<String>(
//                           icon: Icon(
//                             Icons.menu,
//                             size: 35.0,
//                             color: Colors.black,
//                           ),
//                           onSelected: (value) {
//                             if (value == 'logout') {
//                               signUserOut();
//                             } else if (value == 'account') {
//                               navigateToAccountPage(context);
//                             }
//                           },
//                           itemBuilder: (BuildContext context) => [
//                             PopupMenuItem<String>(
//                               value: 'account',
//                               child: Row(
//                                 children: [
//                                   Icon(Icons.account_box_outlined),
//                                   SizedBox(width: 10.0),
//                                   Text('Account'),
//                                 ],
//                               ),
//                             ),
//                             PopupMenuItem<String>(
//                               value: 'logout',
//                               child: Row(
//                                 children: [
//                                   Icon(Icons.logout),
//                                   SizedBox(width: 10.0),
//                                   Text('Log out'),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   Container(
//                     decoration:
//                         BoxDecoration(borderRadius: BorderRadius.circular(12)),
//                     child: Padding(
//                       padding: EdgeInsets.all(12),
//                       child: TextField(
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         // onChanged: (keyword) {
//                         //   setState(() {
//                         //     isSearching = keyword.isNotEmpty;
//                         //   });
//                         //   homeController.searchKeyword(keyword);
//                         // },
//                         decoration: InputDecoration(
//                           prefixIcon: Icon(Icons.search),
//                           hintText: 'Search',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 25,
//                   ),
                
//               Container(
//                 height: 300,
//               child: ListView.builder(
//                 itemCount: favoriteVideos.length,
//                 itemBuilder: (context, index) {
//                   final video = favoriteVideos[index];
//                   return GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => PlayListScreen(
//                             initVideo: video,
//                             listVideo: favoriteVideos,
//                           ),
//                         ),
//                       );
//                     },
//                     child: ChewieListItem(
//                       videoPlayerController: VideoPlayerController.network(
//                         video.url,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
            
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class ChewieListItem extends StatefulWidget {
//   final VideoPlayerController videoPlayerController;

//   ChewieListItem({required this.videoPlayerController});

//   @override
//   State<ChewieListItem> createState() => _ChewieListItemState();
// }

// class _ChewieListItemState extends State<ChewieListItem> {
//   late ChewieController _chewieController;

//   @override
//   void initState() {
//     super.initState();
//     _chewieController = ChewieController(
//       videoPlayerController: widget.videoPlayerController,
//       autoPlay: false,
//       looping: false,
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     widget.videoPlayerController.dispose();
//     _chewieController.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Chewie(
//         controller: _chewieController,
//       ),
//     );
//   }
// }