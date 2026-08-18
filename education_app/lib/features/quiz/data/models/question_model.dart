import '../../domain/entities/question.dart';
import 'detailed_answer_model.dart';
import 'content_image_model.dart';

class QuestionModel extends Question {
  const QuestionModel({
    required super.id,
    required super.topicId,
    required super.questionText,
    required super.option1,
    required super.option2,
    required super.option3,
    required super.option4,
    required super.correctOption,
    super.questionFullImage,
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
      id: json['id'] as int? ?? 0,
      topicId: json['topicId'] as int? ?? 0,
      questionText: json['questionText'] as String? ?? '',
      option1: json['option1'] as String? ?? '',
      option2: json['option2'] as String? ?? '',
      option3: json['option3'] as String? ?? '',
      option4: json['option4'] as String? ?? '',
      correctOption: json['correctOption'] as int? ?? 0,
      questionFullImage: json['questionFullImage'] as String?,
      questionImages: (json['questionImages'] as List<dynamic>?)
              ?.map((e) => ContentImageModel.fromJson(e))
              .toList() ??
          [],
      questionDesigner: json['questionDesigner'] as String?,
      questionYear: json['questionYear'] as int? ?? 0,
      difficultyLevelId: json['difficultyLevelId'] as int? ?? 0,
      difficultyLevelName: json['difficultyLevelName'] as String?,
      detailedAnswer: json['detailedAnswer'] != null
          ? DetailedAnswerModel.fromJson(json['detailedAnswer'])
          : null,
      isLiked: json['isLiked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topicId': topicId,
      'questionText': questionText,
      'option1': option1,
      'option2': option2,
      'option3': option3,
      'option4': option4,
      'correctOption': correctOption,
      'questionFullImage': questionFullImage,
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
