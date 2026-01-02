import 'package:equatable/equatable.dart';
import 'content_image.dart';
import 'detailed_answer.dart';

class Question extends Equatable {
  final int id;
  final int topicItemId;
  final String questionText;
  final String option1;
  final String option2;
  final String option3;
  final String option4;
  final int correctOption;
  final List<ContentImage> questionImages;
  final String? questionDesigner;
  final int questionYear;
  final int difficultyLevelId;
  final String? difficultyLevelName;
  final DetailedAnswer? detailedAnswer;
  final bool isLiked;

  const Question({
    required this.id,
    required this.topicItemId,
    required this.questionText,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.option4,
    required this.correctOption,
    required this.questionImages,
    this.questionDesigner,
    required this.questionYear,
    required this.difficultyLevelId,
    this.difficultyLevelName,
    this.detailedAnswer,
    this.isLiked = false,
  });

  @override
  List<Object?> get props => [
    id, topicItemId, questionText, option1, option2, option3, option4, correctOption,
    questionImages, questionDesigner, questionYear, difficultyLevelId, difficultyLevelName, detailedAnswer, isLiked
  ];
}
