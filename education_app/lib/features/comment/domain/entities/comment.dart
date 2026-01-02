import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final int id;
  final int userId;
  final String userDisplayName;
  final String? userAvatar;
  final String content;
  final int likeCount;
  final String createdAt;
  final List<Comment> replies;
  final bool isLikedByCurrentUser;

  const Comment({
    required this.id,
    required this.userId,
    required this.userDisplayName,
    this.userAvatar,
    required this.content,
    required this.likeCount,
    required this.createdAt,
    this.replies = const [],
    this.isLikedByCurrentUser = false,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        userDisplayName,
        userAvatar,
        content,
        likeCount,
        createdAt,
        replies,
        isLikedByCurrentUser,
      ];
}
