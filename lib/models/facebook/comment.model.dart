class CommentsFacebookModel {
  final String commentsId;
  final String newsId;
  final String userId;
  final DateTime createdAt;
  final String commentContent;

  const CommentsFacebookModel({
    required this.commentsId,
    required this.newsId,
    required this.userId,
    required this.createdAt,
    required this.commentContent,
  });

  Map<String, dynamic> toJson() => {
    "commentsId": commentsId,
    "newsId": newsId,
    "userId": userId,
    "createdAt": createdAt.toIso8601String(),
    "commentContent": commentContent,
  };

  // Assuming a similar fromJson method exists for converting a JSON map to an instance of CommentsFacebookModel
  static CommentsFacebookModel fromJson(Map<String, dynamic> json) => CommentsFacebookModel(
    commentsId: json['commentsId'],
    newsId: json['newsId'],
    userId: json['userId'],
    createdAt: DateTime.parse(json['createdAt']),
    commentContent: json['commentContent'],
  );
}