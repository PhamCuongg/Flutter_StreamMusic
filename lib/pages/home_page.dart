import 'package:CTub/pages/info_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:CTub/controller/home_controller.dart';
import 'package:CTub/model/video.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'account_page.dart';
import 'song_item_widget.dart';

void signUserOut() {
  FirebaseAuth.instance.signOut();
}

class HomePage extends StatefulWidget  {
  HomePage({Key? key}) : super(key: key);

  final user = FirebaseAuth.instance.currentUser;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  final homeController = HomeController();

  bool isSearching = false;

  void navigateToInformationPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InfoPage()),
    );
  }

  @override
  void initState() {
    homeController.getVidId();
    super.initState();
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
                        "Home Page",
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
                                  Text('info'),
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
                  Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: TextField(
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        onChanged: (keyword) {
                          setState(() {
                            isSearching = keyword.isNotEmpty;
                          });
                          homeController.searchKeyword(keyword);
                        },
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            )),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                ],
              ),
            ),
            Container(
              child: Expanded(
                child: Obx(() {
                  if (isSearching && homeController.searchResult.isNotEmpty) {
                    return ListView.builder(
                      itemCount: homeController.searchResult.length,
                      itemBuilder: (context, index) {
                        return SongItemWidget(
                          initVideo: homeController.searchResult[index],
                          videos: homeController.docs.value,
                        );
                      },
                    );
                  } else {
                    return ListView.builder(
                      itemCount: homeController.docs.value.length,
                      itemBuilder: (context, index) {
                        return SongItemWidget(
                          initVideo: homeController.docs.value[index],
                          videos: homeController.docs.value,
                        );
                      },
                    );
                  }
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
