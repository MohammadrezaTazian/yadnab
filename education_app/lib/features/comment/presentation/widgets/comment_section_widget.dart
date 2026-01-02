import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:education_app/injection_container.dart';
import '../bloc/comment_bloc.dart';
import '../../domain/entities/comment.dart';
import 'like_button.dart';

class CommentSectionWidget extends StatelessWidget {
  final int targetId;
  final int targetType;

  const CommentSectionWidget({
    super.key,
    required this.targetId,
    required this.targetType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CommentBloc>()
        ..add(LoadCommentsEvent(targetId: targetId, targetType: targetType)),
      child: _CommentList(targetId: targetId, targetType: targetType),
    );
  }
}

class _CommentList extends StatefulWidget {
  final int targetId;
  final int targetType;

  const _CommentList({required this.targetId, required this.targetType});

  @override
  State<_CommentList> createState() => _CommentListState();
}

class _CommentListState extends State<_CommentList> {
  final TextEditingController _controller = TextEditingController();
  int? _replyToCommentId;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitComment() {
    if (_controller.text.trim().isEmpty) return;

    context.read<CommentBloc>().add(AddCommentEvent(
      targetId: widget.targetId,
      targetType: widget.targetType,
      content: _controller.text.trim(),
      parentCommentId: _replyToCommentId,
    ));

    _controller.clear();
    setState(() {
      _replyToCommentId = null; // Reset reply mode
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'نظرات',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        BlocBuilder<CommentBloc, CommentState>(
          builder: (context, state) {
            if (state is CommentLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CommentError) {
              return Center(child: Text('خطا: ${state.message}'));
            } else if (state is CommentLoaded) {
              if (state.comments.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('هنوز نظری ثبت نشده است. اولین نفر باشید!')),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.comments.length,
                itemBuilder: (context, index) {
                  return _CommentItem(
                    comment: state.comments[index],
                    onReply: (commentId) {
                      setState(() {
                        _replyToCommentId = commentId;
                      });
                    },
                    onLike: (commentId) {
                      context.read<CommentBloc>().add(ToggleLikeEvent(
                        targetId: commentId,
                        targetType: 4, // 4 for Comment
                        parentTargetId: widget.targetId,
                        parentTargetType: widget.targetType,
                      ));
                    },
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          if (_replyToCommentId != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const Text('در پاسخ به نظر...'), // Could show user name if we had it easily
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {
                      setState(() {
                        _replyToCommentId = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'نظر خود را بنویسید...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  minLines: 1,
                  maxLines: 3,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _submitComment,
                icon: const Icon(Icons.send),
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  final Comment comment;
  final Function(int) onReply;
  final Function(int) onLike;

  const _CommentItem({
    required this.comment,
    required this.onReply,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: comment.userAvatar != null
                    ? NetworkImage(comment.userAvatar!)
                    : null,
                child: comment.userAvatar == null
                    ? const Icon(Icons.person, size: 20)
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                comment.userDisplayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                comment.createdAt,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 40.0, top: 4.0),
            child: Text(comment.content),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 32.0),
            child: Row(
              children: [
                LikeButton(
                  isLiked: comment.isLikedByCurrentUser,
                  likeCount: comment.likeCount,
                  onTap: () => onLike(comment.id),
                ),
                TextButton(
                  onPressed: () => onReply(comment.id),
                  child: const Text('پاسخ', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          // Replies
          if (comment.replies.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 24.0),
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey, width: 1)),
              ),
              child: Column(
                children: comment.replies
                    .map((reply) => _CommentItem(
                          comment: reply,
                          onReply: onReply,
                          onLike: onLike,
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
