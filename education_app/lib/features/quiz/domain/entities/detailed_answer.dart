import 'package:equatable/equatable.dart';
import 'content_image.dart';

class DetailedAnswer extends Equatable {
  final int id;
  final int questionId;
  final String answerText;
  final List<ContentImage> answerImages;
  final String? answerAuthor;
  final int answerYear;
  final bool isLiked;

  const DetailedAnswer({
    required this.id,
    required this.questionId,
    required this.answerText,
    required this.answerImages,
    this.answerAuthor,
    required this.answerYear,
    this.isLiked = false,
  });

  @override
  List<Object?> get props => [id, questionId, answerText, answerImages, answerAuthor, answerYear, isLiked];
}
