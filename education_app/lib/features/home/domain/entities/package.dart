import 'package:equatable/equatable.dart';

class Package extends Equatable {
  final int id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final double price;

  const Package({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.price,
  });

  @override
  List<Object?> get props => [id, title, description, category, imageUrl, price];
}
