import 'package:bloc/bloc.dart';
import 'package:education_app/features/upload/data/repositories/upload_repository_impl.dart';
import 'package:education_app/features/upload/presentation/bloc/upload_event.dart';
import 'package:education_app/features/upload/presentation/bloc/upload_state.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  final UploadRepository repository;

  UploadBloc({required this.repository}) : super(const UploadState()) {
    on<SearchEntitiesEvent>(_onSearchEntities);
    on<SelectEntityEvent>(_onSelectEntity);
    on<PickImageEvent>(_onPickImage);
    on<UploadImageEvent>(_onUploadImage);
    on<ResetUploadEvent>(_onResetUpload);
  }

  Future<void> _onSearchEntities(
    SearchEntitiesEvent event,
    Emitter<UploadState> emit,
  ) async {
    // Reset state but keep status as searching
    emit(const UploadState(status: UploadStatus.searching));

    final result = await repository.searchEntities(
      event.entityTypeId,
      event.searchText,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: UploadStatus.searchError,
        errorMessage: 'خطا در جستجوی محتوا',
      )),
      (searchResults) => emit(state.copyWith(
        status: UploadStatus.searchLoaded,
        searchResults: searchResults,
      )),
    );
  }

  void _onSelectEntity(
    SelectEntityEvent event,
    Emitter<UploadState> emit,
  ) {
    emit(state.copyWith(
      selectedEntityId: event.entityId,
      selectedEntityTitle: event.entityTitle,
    ));
  }

  void _onPickImage(
    PickImageEvent event,
    Emitter<UploadState> emit,
  ) {
    emit(state.copyWith(selectedImage: event.image));
  }

  Future<void> _onUploadImage(
    UploadImageEvent event,
    Emitter<UploadState> emit,
  ) async {
    if (state.selectedImage == null) {
      emit(state.copyWith(errorMessage: 'لطفا یک تصویر انتخاب کنید'));
      return;
    }

    emit(state.copyWith(status: UploadStatus.uploading, errorMessage: null));

    final result = await repository.uploadImage(
      event.entityTypeId,
      event.entityId,
      state.selectedImage!,
      event.altText,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: UploadStatus.error,
        errorMessage: 'خطا در آپلود تصویر',
      )),
      (_) => emit(state.copyWith(
        status: UploadStatus.success,
        selectedImage: null, // Clear image after success
        selectedEntityId: null, // Reset selection
        selectedEntityTitle: null,
      )),
    );
  }

  void _onResetUpload(ResetUploadEvent event, Emitter<UploadState> emit) {
    emit(const UploadState());
  }
}
