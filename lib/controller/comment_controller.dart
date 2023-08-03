// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';

// import '../model/comment.dart';

// class CommentController extends GetxController {
//   final TextEditingController commentController = TextEditingController();
//   final Rxn<List<CommentModel>> comments = Rxn<List<CommentModel>>();

//   void postComment(String videoId) async {
//     final commentText = commentController.text.trim();
//     if (commentText.isNotEmpty) {
//       final currentUser = FirebaseAuth.instance.currentUser;
//       final username = currentUser?.email?.split('@')[0];

//       if (username != null) {
//         final userSnapshot = await FirebaseFirestore.instance
//             .collection('Users')
//             .where('username', isEqualTo: username)
//             .get();

//         if (userSnapshot.docs.isNotEmpty) {
//           final userData =
//               userSnapshot.docs.first.data() as Map<String, dynamic>;
//           final profileImage = userData['profileImage'];

//           final newComment = {
//             'commentText': commentText,
//             'userId': currentUser?.uid,
//             'username': username,
//             'videoId': videoId,
//             'profileImage': profileImage,
//           };

//           final result = await FirebaseFirestore.instance
//               .collection('comment')
//               .add(newComment);
//           final data = await result.get();
//           comments.value!.add(CommentModel.fromSnapshot(data));
//           comments.refresh();
//           commentController.clear();
//         } else {
//           print('User not found');
//         }
//       } else {
//         print('Username not found');
//       }
//     }
//   }
// }
