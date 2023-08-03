import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class DownloadController extends GetxController {
  RxMap<String, bool> downloadCompleted = RxMap<String, bool>();

  void setDownloadCompleted({required String videoId, required bool value}) {
    downloadCompleted[videoId] = value;
  }
}


