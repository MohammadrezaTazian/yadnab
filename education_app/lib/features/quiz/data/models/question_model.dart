import '../../domain/entities/question.dart';
import 'detailed_answer_model.dart';
import 'content_image_model.dart';

class QuestionModel extends Question {
  const QuestionModel({
    required super.id,
    required super.topicItemId,
    required super.questionText,
    required super.option1,
    required super.option2,
    required super.option3,
    required super.option4,
    required super.correctOption,
    required List<ContentImageModel> questionImages,
    super.questionDesigner,
    required super.questionYear,
    required super.difficultyLevelId,
    super.difficultyLevelName,
    DetailedAnswerModel? detailedAnswer,
    super.isLiked = false,
  }) : super(questionImages: questionImages, detailedAnswer: detailedAnswer);

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'],
      topicItemId: json['topicItemId'],
      questionText: json['questionText'],
      option1: json['option1'],
      option2: json['option2'],
      option3: json['option3'],
      option4: json['option4'],
      correctOption: json['correctOption'],
      questionImages: (json['questionImages'] as List<dynamic>?)
              ?.map((e) => ContentImageModel.fromJson(e))
              .toList() ??
          [],
      questionDesigner: json['questionDesigner'],
      questionYear: json['questionYear'] ?? 0,
      difficultyLevelId: json['difficultyLevelId'],
      difficultyLevelName: json['difficultyLevelName'],
      detailedAnswer: json['detailedAnswer'] != null
          ? DetailedAnswerModel.fromJson(json['detailedAnswer'])
          : null,
      isLiked: json['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topicItemId': topicItemId,
      'questionText': questionText,
      'option1': option1,
      'option2': option2,
      'option3': option3,
      'option4': option4,
      'correctOption': correctOption,
      'questionImages': questionImages
          .map((e) => (e as ContentImageModel).toJson())
          .toList(),
      'questionDesigner': questionDesigner,
      'questionYear': questionYear,
      'difficultyLevelId': difficultyLevelId,
      'difficultyLevelName': difficultyLevelName,
      'detailedAnswer': (detailedAnswer as DetailedAnswerModel?)?.toJson(),
    };
  }
}
