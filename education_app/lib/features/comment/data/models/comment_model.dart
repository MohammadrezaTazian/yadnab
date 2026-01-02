import '../../domain/entities/comment.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.userId,
    required super.userDisplayName,
    super.userAvatar,
    required super.content,
    required super.likeCount,
    required super.createdAt,
    List<CommentModel> replies = const [],
    super.isLikedByCurrentUser = false,
  }) : super(replies: replies);

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      userId: json['userId'],
      userDisplayName: json['userDisplayName'] ?? 'User',
      userAvatar: json['userAvatar'],
      content: json['content'],
      likeCount: json['likeCount'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      isLikedByCurrentUser: json['isLikedByCurrentUser'] ?? false,
      replies: json['replies'] != null
          ? (json['replies'] as List)
              .map((e) => CommentModel.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userDisplayName': userDisplayName,
      'userAvatar': userAvatar,
      'content': content,
      'likeCount': likeCount,
      'createdAt': createdAt,
      'replies': replies.map((e) => (e as CommentModel).toJson()).toList(),
    };
  }
}
