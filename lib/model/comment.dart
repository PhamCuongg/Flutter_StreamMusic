class Comment {
  final String commentId;
  final String commentText;
  final String userId;
  final String username;
  final String videoId;
  final String profileImage;

  Comment({
    required this.commentId,
    required this.commentText,
    required this.userId,
    required this.username,
    required this.videoId,
    required this.profileImage,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentId: json['commentId'],
      commentText: json['commentText'],
      userId: json['userId'],
      username: json['username'],
      videoId: json['videoId'],
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'commentText': commentText,
      'userId': userId,
      'username': username,
      'videoId': videoId,
      'profileImage': profileImage,
    };
  }
}
