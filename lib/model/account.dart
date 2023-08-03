class AccountModel {
  final String id;
  final String email;
  final String profileImage;
  final String username;

  AccountModel({
    required this.id,
    required this.email,
    required this.profileImage,
    required this.username,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'],
      email: json['email'],
      profileImage: json['profileImage'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'profileImage': profileImage,
      'username': username,
    };
  }
}
