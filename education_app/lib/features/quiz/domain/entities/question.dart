import 'package:equatable/equatable.dart';
import 'content_image.dart';
import 'detailed_answer.dart';

class Question extends Equatable {
  final int id;
  final int topicId;
  final String questionText;
  final String option1;
  final String option2;
  final String option3;
  final String option4;
  final int correctOption;
  final String? questionFullImage;
  final List<ContentImage> questionImages;
  final String? questionDesigner;
  final int questionYear;
  final int difficultyLevelId;
  final String? difficultyLevelName;
  final DetailedAnswer? detailedAnswer;
  final bool isLiked;

  const Question({
    required this.id,
    required this.topicId,
    required this.questionText,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.option4,
    required this.correctOption,
    this.questionFullImage,
    required this.questionImages,
    this.questionDesigner,
    required this.questionYear,
    required this.difficultyLevelId,
    this.difficultyLevelName,
    this.detailedAnswer,
    this.isLiked = false,
  });

  /// Returns the full-page image URL if available
  String? get fullPageImage {
    if (questionFullImage != null && questionFullImage!.isNotEmpty) {
      return questionFullImage;
    }
    for (final img in questionImages) {
      if (img.imageTypeId == 1) {
        return img.imageUrl;
      }
    }
    return null;
  }

  /// Returns embedded images excluding full page image
  List<ContentImage> get contentImages {
    return questionImages.where((img) => img.imageTypeId != 1).toList();
  }

  @override
  List<Object?> get props => [
    id, topicId, questionText, option1, option2, option3, option4, correctOption,
    questionFullImage, questionImages, questionDesigner, questionYear, difficultyLevelId,
    difficultyLevelName, detailedAnswer, isLiked
  ];
}
