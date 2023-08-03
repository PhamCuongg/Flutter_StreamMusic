
import 'package:CTub/objectbox.g.dart';

import '../model/local_db.dart';
import '../objectbox.dart';

class MyMusicDB {

  factory MyMusicDB() => _singleton;
  MyMusicDB._();
  static final MyMusicDB _singleton = MyMusicDB._();

 late ObjectBox _objectbox;
 late Box<MyMusic> _myMusicBox;
  
  void init(ObjectBox ob)  {
    _objectbox = ob;
    _myMusicBox = _objectbox.musicBox;
  }


  void close(){
    _objectbox.onClose();
  }

void insetMyMusic(MyMusic video){
  _myMusicBox.put(video);
}

List<MyMusic> getALlMusic(){
 return _myMusicBox.getAll();
}

bool isVideoDownloaded(String videoId) {
  final query = _myMusicBox.query(MyMusic_.id.equals(int.parse(videoId))).build();
  return query.count() > 0;
}

  
}
