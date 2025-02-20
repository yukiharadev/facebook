

class PostFacebookModel {
  final String postId;
  final String content;
  final String userId;
  final List<String> imageUrls;
  final DateTime createdAt;
  late int likes;
  final List<String>? likesUserId;

   PostFacebookModel({
    required this.postId,
    required this.content,
    required this.userId,
    required this.imageUrls,
    required this.createdAt,
    required this.likes,
    required this.likesUserId,
  });

  Map<String, dynamic> toJson() => {
        "postId": postId,
        "content": content,
        "userId": userId,
        "imageUrls": imageUrls,
        "createdAt": createdAt.toIso8601String(),
        "likes": likes,
        "likesUserId": likesUserId,

      };

  factory PostFacebookModel.fromJson(Map<String, dynamic> json) {
    return PostFacebookModel(
      postId: json['postId'],
      content: json['content'],
      userId: json['userId'],
      imageUrls: List<String>.from(json['imageUrls']),
      createdAt: DateTime.parse(json['createdAt']),
      likes: json['likes'],
      likesUserId: List<String>.from(json['likesUserId']??[]),
    );
  }
}

