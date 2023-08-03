import 'package:objectbox/objectbox.dart';

@Entity()
class MyMusic {
  @Id(assignable: true)
  int id;
  String name;
  String author;
  String url;
  String image;

  MyMusic({this.id = 0 ,  required this.objectId, required this.name, required this.author, required this.url, required this.image});

  String  objectId;

  @override
  String toString() {
    return 'MyMusic{id: $id, name: $name, author: $author, url: $url, image: $image}';
  }
}

