class MainVideo {
  final String name;
  final String author;
  final String imageUrl;
  final String url;

  const MainVideo({
    required this.name,
    required this.author,
    required this.imageUrl,
    required this.url,
  });

  factory MainVideo.fromJson(Map<String, dynamic> json) {
    return MainVideo(
      name: json['name'],
      author: json['author'],
      imageUrl: json['image'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'author': author,
      'image': imageUrl,
      'url': url,
    };
  }
}

class UserModel {
  final String username;
  final String email;
  final String profileImage;

  const UserModel({
    required this.username,
    required this.email,
    required this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
      email: json['email'],
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'profileImage': profileImage,
    };
  }
}
