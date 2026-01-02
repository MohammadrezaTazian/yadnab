import '../../domain/entities/detailed_answer.dart';
import 'content_image_model.dart';

class DetailedAnswerModel extends DetailedAnswer {
  const DetailedAnswerModel({
    required super.id,
    required super.questionId,
    required super.answerText,
    required List<ContentImageModel> answerImages,
    super.answerAuthor,
    required super.answerYear,
    super.isLiked = false,
  }) : super(answerImages: answerImages);

  factory DetailedAnswerModel.fromJson(Map<String, dynamic> json) {
    return DetailedAnswerModel(
      id: json['id'],
      questionId: json['questionId'],
      answerText: json['answerText'],
      answerImages: (json['answerImages'] as List<dynamic>?)
              ?.map((e) => ContentImageModel.fromJson(e))
              .toList() ??
          [],
      answerAuthor: json['answerAuthor'],
      answerYear: json['answerYear'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'answerText': answerText,
      'answerImages': answerImages
          .map((e) => (e as ContentImageModel).toJson())
          .toList(),
      'answerAuthor': answerAuthor,
      'answerYear': answerYear,
    };
  }
}
