import 'package:education_app/features/home/domain/entities/package.dart';

class PackageModel extends Package {
  const PackageModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.imageUrl,
    required super.price,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}
