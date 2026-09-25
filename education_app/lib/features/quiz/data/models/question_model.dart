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
      id: (json['id'] as num?)?.toInt() ?? 0,
      topicId: (json['topicId'] as num?)?.toInt() ?? 0,
      questionText: json['questionText'] as String? ?? '',
      option1: json['option1'] as String? ?? '',
      option2: json['option2'] as String? ?? '',
      option3: json['option3'] as String? ?? '',
      option4: json['option4'] as String? ?? '',
      correctOption: (json['correctOption'] as num?)?.toInt() ?? 0,
      questionFullImage: json['questionFullImage'] as String?,
      questionImages: (json['questionImages'] as List<dynamic>?)
              ?.map((e) => e is ContentImageModel
                  ? e
                  : ContentImageModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      questionDesigner: json['questionDesigner'] as String?,
      questionYear: (json['questionYear'] as num?)?.toInt() ?? 0,
      difficultyLevelId: (json['difficultyLevelId'] as num?)?.toInt() ?? 0,
      difficultyLevelName: json['difficultyLevelName'] as String?,
      detailedAnswer: json['detailedAnswer'] != null
          ? (json['detailedAnswer'] is DetailedAnswerModel
              ? json['detailedAnswer'] as DetailedAnswerModel
              : DetailedAnswerModel.fromJson(Map<String, dynamic>.from(json['detailedAnswer'] as Map)))
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
          .map((e) => e is ContentImageModel
              ? e.toJson()
              : ContentImageModel(
                  id: e.id,
                  imageUrl: e.imageUrl,
                  displayOrder: e.displayOrder,
                  altText: e.altText,
                  imageTypeId: e.imageTypeId,
                ).toJson())
          .toList(),
      'questionDesigner': questionDesigner,
      'questionYear': questionYear,
      'difficultyLevelId': difficultyLevelId,
      'difficultyLevelName': difficultyLevelName,
      'detailedAnswer': detailedAnswer is DetailedAnswerModel
          ? (detailedAnswer as DetailedAnswerModel).toJson()
          : (detailedAnswer != null
              ? DetailedAnswerModel(
                  id: detailedAnswer!.id,
                  questionId: detailedAnswer!.questionId,
                  answerText: detailedAnswer!.answerText,
                  fullAnswerImage: detailedAnswer!.fullAnswerImage,
                  answerImages: detailedAnswer!.answerImages
                      .map((img) => img is ContentImageModel
                          ? img
                          : ContentImageModel(
                              id: img.id,
                              imageUrl: img.imageUrl,
                              displayOrder: img.displayOrder,
                              altText: img.altText,
                              imageTypeId: img.imageTypeId,
                            ))
                      .toList(),
                  answerAuthor: detailedAnswer!.answerAuthor,
                  answerYear: detailedAnswer!.answerYear,
                  isLiked: detailedAnswer!.isLiked,
                ).toJson()
              : null),
      'isLiked': isLiked,
    };
  }
}
