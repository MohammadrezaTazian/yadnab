import 'package:equatable/equatable.dart';

class Topic extends Equatable {
  final int id;
  final int? parentId;
  final String title;
  final String? imageUrl;
  final List<Topic> children;

  const Topic({
    required this.id,
    this.parentId,
    required this.title,
    this.imageUrl,
    this.children = const [],
  });

  @override
  List<Object?> get props => [id, parentId, title, imageUrl, children];
}
