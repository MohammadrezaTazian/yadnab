import 'package:equatable/equatable.dart';

class ContentImage extends Equatable {
  final int id;
  final String imageUrl;
  final int displayOrder;
  final String? altText;

  const ContentImage({
    required this.id,
    required this.imageUrl,
    required this.displayOrder,
    this.altText,
  });

  @override
  List<Object?> get props => [id, imageUrl, displayOrder, altText];
}
