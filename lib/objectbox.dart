import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'model/local_db.dart';
import 'objectbox.g.dart'; 

class ObjectBox {
  late final Store _store;
  late final Box<MyMusic> musicBox;

  ObjectBox._create(this._store) {
    musicBox = Box<MyMusic>(_store);
  }

  static Future<ObjectBox> create() async {
    final store = await openStore(
        directory: p.join(
            (await getApplicationDocumentsDirectory()).path, "database"));
    return ObjectBox._create(store);
  }

  onClose(){
    _store.close();
  }

}
