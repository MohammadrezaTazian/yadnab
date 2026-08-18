import 'package:equatable/equatable.dart';

class ContentImage extends Equatable {
  final int id;
  final String imageUrl;
  final int displayOrder;
  final String? altText;
  final int imageTypeId;

  const ContentImage({
    required this.id,
    required this.imageUrl,
    required this.displayOrder,
    this.altText,
    this.imageTypeId = 6,
  });

  bool get isFullPage => imageTypeId == 1;

  @override
  List<Object?> get props => [id, imageUrl, displayOrder, altText, imageTypeId];
}
