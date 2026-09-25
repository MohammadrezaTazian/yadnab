import '../../domain/entities/detailed_answer.dart';
import 'content_image_model.dart';

class DetailedAnswerModel extends DetailedAnswer {
  const DetailedAnswerModel({
    required super.id,
    required super.questionId,
    required super.answerText,
    super.fullAnswerImage,
    required List<ContentImageModel> answerImages,
    super.answerAuthor,
    required super.answerYear,
    super.isLiked = false,
  }) : super(answerImages: answerImages);

  factory DetailedAnswerModel.fromJson(Map<String, dynamic> json) {
    return DetailedAnswerModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      questionId: (json['questionId'] as num?)?.toInt() ?? 0,
      answerText: json['answerText'] as String? ?? '',
      fullAnswerImage: json['fullAnswerImage'] as String?,
      answerImages: (json['answerImages'] as List<dynamic>?)
              ?.map((e) => e is ContentImageModel
                  ? e
                  : ContentImageModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      answerAuthor: json['answerAuthor'] as String?,
      answerYear: (json['answerYear'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'answerText': answerText,
      'fullAnswerImage': fullAnswerImage,
      'answerImages': answerImages
          .map((e) => (e as ContentImageModel).toJson())
          .toList(),
      'answerAuthor': answerAuthor,
      'answerYear': answerYear,
    };
  }
}
