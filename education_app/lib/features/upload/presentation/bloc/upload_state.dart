import 'package:education_app/features/upload/data/models/entity_search_result.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

enum UploadStatus { initial, searching, searchLoaded, searchError, uploading, success, error }

class UploadState extends Equatable {
  final UploadStatus status;
  final List<EntitySearchResult> searchResults;
  final String? errorMessage;
  final int? selectedEntityId;
  final String? selectedEntityTitle;
  final XFile? selectedImage;

  const UploadState({
    this.status = UploadStatus.initial,
    this.searchResults = const [],
    this.errorMessage,
    this.selectedEntityId,
    this.selectedEntityTitle,
    this.selectedImage,
  });

  UploadState copyWith({
    UploadStatus? status,
    List<EntitySearchResult>? searchResults,
    String? errorMessage,
    int? selectedEntityId,
    String? selectedEntityTitle,
    XFile? selectedImage,
  }) {
    return UploadState(
      status: status ?? this.status,
      searchResults: searchResults ?? this.searchResults,
      errorMessage: errorMessage, // Nullable to clear error
      selectedEntityId: selectedEntityId ?? this.selectedEntityId,
      selectedEntityTitle: selectedEntityTitle ?? this.selectedEntityTitle,
      selectedImage: selectedImage ?? this.selectedImage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        searchResults,
        errorMessage,
        selectedEntityId,
        selectedEntityTitle,
        selectedImage,
      ];
}
