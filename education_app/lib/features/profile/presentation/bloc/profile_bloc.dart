import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:education_app/features/profile/domain/usecases/profile_usecases.dart';
import 'package:education_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:education_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:education_app/core/services/api_service.dart';
import 'package:education_app/features/auth/domain/entities/user.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final GetEducationalLevelsUseCase getEducationalLevelsUseCase;
  final ApiService apiService;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.getEducationalLevelsUseCase,
    required this.apiService,
  }) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<LoadEducationalLevelsEvent>(_onLoadEducationalLevels);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UpdateProfilePictureEvent>(_onUpdateProfilePicture);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileLoading());
      
      final user = await getProfileUseCase();
      final educationalLevels = await getEducationalLevelsUseCase();
      
      emit(ProfileLoaded(user: user, educationalLevels: educationalLevels));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onLoadEducationalLevels(
    LoadEducationalLevelsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final educationalLevels = await getEducationalLevelsUseCase();
      
      if (state is ProfileLoaded) {
        final currentState = state as ProfileLoaded;
        emit(ProfileLoaded(user: currentState.user, educationalLevels: educationalLevels));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (state is ProfileLoaded) {
        final currentState = state as ProfileLoaded;
        emit(ProfileUpdating(user: currentState.user, educationalLevels: currentState.educationalLevels));
        
        final updatedUser = await updateProfileUseCase(
          firstName: event.firstName,
          lastName: event.lastName,
          email: event.email,
          educationalLevelId: event.educationalLevelId,
        );
        
        emit(ProfileLoaded(user: updatedUser, educationalLevels: currentState.educationalLevels));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfilePicture(
    UpdateProfilePictureEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (state is ProfileLoaded) {
        final currentState = state as ProfileLoaded;
        emit(ProfileUpdating(user: currentState.user, educationalLevels: currentState.educationalLevels));
        
        final response = await apiService.updateProfilePicture(event.base64Image);
        
        // Create updated user with new profile picture
        final updatedUser = User(
          id: currentState.user.id,
          phoneNumber: currentState.user.phoneNumber,
          firstName: currentState.user.firstName,
          lastName: currentState.user.lastName,
          email: currentState.user.email,
          educationalLevelId: currentState.user.educationalLevelId,
          educationalLevelName: currentState.user.educationalLevelName,
          profilePicture: response['profilePicture'],
        );
        
        emit(ProfileLoaded(user: updatedUser, educationalLevels: currentState.educationalLevels));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}

