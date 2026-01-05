import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class UploadEvent extends Equatable {
  const UploadEvent();

  @override
  List<Object?> get props => [];
}

class SearchEntitiesEvent extends UploadEvent {
  final int entityTypeId;
  final String? searchText;

  const SearchEntitiesEvent(this.entityTypeId, {this.searchText});

  @override
  List<Object?> get props => [entityTypeId, searchText];
}

class SelectEntityEvent extends UploadEvent {
  final int entityId;
  final String entityTitle;

  const SelectEntityEvent(this.entityId, this.entityTitle);

  @override
  List<Object?> get props => [entityId, entityTitle];
}

class PickImageEvent extends UploadEvent {
  final XFile image;

  const PickImageEvent(this.image);

  @override
  List<Object?> get props => [image];
}

class UploadImageEvent extends UploadEvent {
  final int entityTypeId;
  final int entityId;
  final String? altText;

  const UploadImageEvent({
    required this.entityTypeId,
    required this.entityId,
    this.altText,
  });

  @override
  List<Object?> get props => [entityTypeId, entityId, altText];
}

class ResetUploadEvent extends UploadEvent {}
