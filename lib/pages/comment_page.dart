import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:uuid/uuid.dart';

class CommentPage extends StatefulWidget {
  final String videoId;

  CommentPage({required this.videoId});

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController _commentController = TextEditingController();
  final userController = FirebaseFirestore.instance.collection('Users');
  void _postComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isNotEmpty) {
      final currentUser = FirebaseAuth.instance.currentUser;
      final usernameQuery = await userController
          .where('email', isEqualTo: currentUser?.email)
          .limit(1)
          .get();
      if (usernameQuery.docs.isNotEmpty) {
        final userData =
            usernameQuery.docs.first.data() as Map<String, dynamic>;
        final profileImage = userData['profileImage'];
        final username = userData['username'];
        final commentId = Uuid().v4();

        final newComment = {
          'commentId': commentId,
          'commentText': commentText,
          'userId': currentUser?.uid,
          'username': username,
          'videoId': widget.videoId,
          'profileImage': profileImage,
        };

        final result = await FirebaseFirestore.instance
            .collection('comment')
            .add(newComment);
        final data = await result.get();
        _comments.value!.add(data.data());
        _comments.refresh();
        _commentController.clear();
      } else {
        print('User not found');
      }
    }
  }

  void _editComment(String commentId, String currentCommentText) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('comment')
        .where('commentId', isEqualTo: commentId)
        .where('userId', isEqualTo: currentUser?.uid)
        .get();
    final commentDocs = querySnapshot.docs;
    if (commentDocs.isNotEmpty) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Edit Comment',
            style: TextStyle(color: Colors.black),
          ),
          content: TextField(
            autofocus: true,
            style: TextStyle(color: Colors.black),
            controller: TextEditingController(text: currentCommentText),
            decoration: InputDecoration(
              hintText: 'Enter new comment',
              hintStyle: TextStyle(color: Colors.black),
            ),
            onChanged: (value) {
              currentCommentText = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final confirmed = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Confirm Delete'),
                    content: Text('You want to delete this comment?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                          setState(() {
                            onInit();
                            _comments.refresh();
                          });
                        },
                        child:
                            Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  final commentDoc = commentDocs.first;
                  await commentDoc.reference.delete();
                }
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(currentCommentText);
                final commentDoc = commentDocs.first;
                await commentDoc.reference
                    .update({'commentText': currentCommentText});
                final index = _comments.value!
                    .indexWhere((e) => e['commentId'] == commentId);
                if (index >= 0) {
                  _comments.value![index]['commentText'] = currentCommentText;
                  _comments.refresh();
                }
                // setState(() {
                //   onInit();
                //   _comments.refresh();
                // });
              },
              child: Text('Save', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      );
    }
  }

  final _comments = Rxn<List<dynamic>>();
  late String commentId;
  onInit() async {
    try {
      _comments.value = null;
      final data = await FirebaseFirestore.instance
          .collection('comment')
          .where('videoId', isEqualTo: widget.videoId)
          .get();
      _comments.value = data.docs.map((e) => e.data()).toList();
    } catch (_) {
      _comments.value = [];
    }
  }

  @override
  void initState() {
    super.initState();
    onInit();
  }

  @override
  void didUpdateWidget(covariant CommentPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoId != oldWidget.videoId) {
      onInit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () {
                if (_comments.value != null && _comments.value!.isNotEmpty) {
                  final comments = _comments.value ?? [];
                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final commentData = comments[index];
                      final commentText = commentData['commentText'];
                      final username = commentData['username'];
                      final profileImage = commentData['profileImage'];
                      final commentId = commentData['commentId'];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(profileImage),
                        ),
                        title: Text(username),
                        subtitle: Text(commentText),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editComment(commentId, commentText),
                        ),
                      );
                    },
                  );
                } else if (_comments.value != null &&
                    _comments.value!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 250, // Set the desired width
                          height: 250, // Set the desired height
                          child: Lottie.network(
                            'https://lottie.host/aab794f8-a7a7-4a46-8235-f27bd3ea9bd2/bClmHoLpko.json',
                          ),
                        ),
                        Text(
                          'No comments',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: _postComment,
                  child: Text('Post'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
