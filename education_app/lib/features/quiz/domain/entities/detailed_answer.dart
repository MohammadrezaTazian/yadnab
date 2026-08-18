import 'package:equatable/equatable.dart';
import 'content_image.dart';

class DetailedAnswer extends Equatable {
  final int id;
  final int questionId;
  final String answerText;
  final String? fullAnswerImage;
  final List<ContentImage> answerImages;
  final String? answerAuthor;
  final int answerYear;
  final bool isLiked;

  const DetailedAnswer({
    required this.id,
    required this.questionId,
    required this.answerText,
    this.fullAnswerImage,
    required this.answerImages,
    this.answerAuthor,
    required this.answerYear,
    this.isLiked = false,
  });

  /// Returns the full-page image URL if available
  String? get fullPageImage {
    if (fullAnswerImage != null && fullAnswerImage!.isNotEmpty) {
      return fullAnswerImage;
    }
    for (final img in answerImages) {
      if (img.imageTypeId == 1) {
        return img.imageUrl;
      }
    }
    return null;
  }

  /// Returns embedded images excluding full page image
  List<ContentImage> get contentImages {
    return answerImages.where((img) => img.imageTypeId != 1).toList();
  }

  @override
  List<Object?> get props => [
    id, questionId, answerText, fullAnswerImage, answerImages, answerAuthor, answerYear, isLiked
  ];
}
