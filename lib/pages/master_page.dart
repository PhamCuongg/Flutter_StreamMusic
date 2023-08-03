import 'package:CTub/pages/info_page.dart';
import 'package:flutter/material.dart';
import 'package:CTub/pages/storage_download.dart';
import 'package:get/get.dart';

import '../controller/favorite_controller.dart';
import 'account_page.dart';
import 'download_helper.dart';
import 'favoritepage.dart';
import 'uploadpage.dart';
import 'home_page.dart';

class MasterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MasterPageState();
  }
}

class _MasterPageState extends State<MasterPage> {
  final _currentIndex = 0.obs;
  final _pageController = PageController();
  final favoriteController = Get.put(FavoriteController());

  final List<Widget> _widgetOption = <Widget>[
    HomePage(),
    const UploadPage(),
    const StoragePage(),
    const AccountPage()
  ];

  @override
  void initState() {
    super.initState();
    DownloadHelper().init();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        body: PageView.builder(
          controller: _pageController,
          itemCount: _widgetOption.length,
          itemBuilder: (context, index) {
            return _widgetOption[index];
          },
          onPageChanged: (index) {
            _currentIndex.value = index;
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.upload),
              label: 'Upload',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storage),
              label: 'Storage',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_box_outlined),
              label: 'Account',
            ),
          ],
          currentIndex: _currentIndex.value,
          onTap: (index) {
            _currentIndex.value = index;
            _pageController.jumpToPage(index);
          },
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
        ),
      );
    });
  }
}
