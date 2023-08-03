import 'dart:io';

import 'package:CTub/pages/info_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import '../API/firebase_api.dart';
import '../style/button_widget.dart';
import 'account_page.dart';
import 'home_page.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage>
    with AutomaticKeepAliveClientMixin {
  void showDownloadSuccessToast() {
    Fluttertoast.showToast(
        msg: "Upload Successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey,
        textColor: Colors.white);
  }

  void navigateToInformationPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InfoPage()),
    );
  }

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  String? author = '';
  File? file;
  UploadTask? task;
  String? thumbnailPath;
  final _authorController = TextEditingController();

  Future selectFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) return;
    final path = result.files.single.path!;

    final fileExtension = extension(path);
    if (fileExtension != '.mp4') {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Invalid File Format'),
          content: Text('Only files with the .mp4 extension are allowed.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      file = File(path);
      thumbnailPath = null;
    });

    final thumbnail = await FirebaseApi.getVideoThumbnail(file!);
    setState(() {
      thumbnailPath = thumbnail;
    });
  }

  Future uploadFile() async {
    if (file == null) return;

    final fileName = basename(file!.path);
    final destination = 'all/$fileName';
    var thumbnailUrl = '';

    task = FirebaseApi.uploadFile(destination, file!);

    if (thumbnailPath != null) {
      final thumbnailFile = File(thumbnailPath!);
      final thumbnailUploadTask =
          FirebaseApi.uploadFile('video/${thumbnailFile.path}', thumbnailFile);
      await thumbnailUploadTask?.whenComplete(() {});

      thumbnailUrl =
          (await thumbnailUploadTask?.snapshot.ref.getDownloadURL())!;
    }

    setState(() {});

    if (task == null) return;

    final snapshot = await task!.whenComplete(() {
      showDownloadSuccessToast();
    });
    final user = FirebaseAuth.instance.currentUser;
    final urlDownload = await snapshot.ref.getDownloadURL();
    final videoCollection = FirebaseFirestore.instance.collection('video');
    final videoSnapshot = await videoCollection.limit(1).get();
    final id = Uuid().v4();
    if (videoSnapshot.docs.isEmpty) {
      await videoCollection.doc('placeholder').set({
        'placeholder': true,
      });
      await videoCollection.doc('placeholder').delete();
    }
    await videoCollection.add({
      "id": id,
      "name": fileName,
      "author": _authorController.text,
      "image": thumbnailUrl,
      "url": urlDownload,
      "user_upload": user!.email,
    });
  }

  void clearData() {
    setState(() {
      _authorController.clear();
      author = '';
      file = null;
      task = null;
      if (thumbnailPath != null) {
        final thumbnailFile = File(thumbnailPath!);
        thumbnailFile.delete();

        thumbnailPath = null;
      }
    });
  }

  @override
  void dispose() {
    _authorController.dispose();
    super.dispose();
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(2);
            return Text(
              '$percentage %',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            );
          } else {
            return Container();
          }
        },
      );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final fileName =
        file != null ? basenameWithoutExtension(file!.path) : 'No file';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
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
                          "Upload File",
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
                      height: 30,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          controller: _authorController,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          onChanged: (value) {
                            setState(() {
                              author = value;
                            });
                          },
                          textAlign: TextAlign.justify,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.people),
                              hintText: 'Author',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              )),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        if (thumbnailPath != null)
                          Image.file(
                            File(thumbnailPath!),
                            height: 350,
                            width: 350,
                          ),
                        task != null ? buildUploadStatus(task!) : Container(),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          fileName,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        ButtonWidget(
                          icon: Icons.attach_file,
                          onClicked: () => selectFile(context),
                          text: 'Select Video',
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        ButtonWidget(
                          icon: Icons.cloud_upload_outlined,
                          onClicked: uploadFile,
                          text: 'Upload File',
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        ButtonWidget(
                          icon: Icons.cleaning_services_outlined,
                          onClicked: () => clearData(),
                          text: 'Clear all data',
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
