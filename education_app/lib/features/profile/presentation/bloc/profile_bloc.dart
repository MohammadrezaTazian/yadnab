import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:education_app/features/profile/domain/usecases/profile_usecases.dart';
import 'package:education_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:education_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:education_app/core/services/api_service.dart';
import 'package:education_app/features/auth/domain/entities/user.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final GetGradesUseCase getGradesUseCase;
  final ApiService apiService;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.getGradesUseCase,
    required this.apiService,
  }) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<LoadGradesEvent>(_onLoadGrades);
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
      final grades = await getGradesUseCase();
      
      emit(ProfileLoaded(user: user, grades: grades));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onLoadGrades(
    LoadGradesEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final grades = await getGradesUseCase();
      
      if (state is ProfileLoaded) {
        final currentState = state as ProfileLoaded;
        emit(ProfileLoaded(user: currentState.user, grades: grades));
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
        emit(ProfileUpdating(user: currentState.user, grades: currentState.grades));
        
        final updatedUser = await updateProfileUseCase(
          firstName: event.firstName,
          lastName: event.lastName,
          email: event.email,
          grade: event.grade,
        );
        
        emit(ProfileLoaded(user: updatedUser, grades: currentState.grades));
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
        emit(ProfileUpdating(user: currentState.user, grades: currentState.grades));
        
        final response = await apiService.updateProfilePicture(event.base64Image);
        
        // Create updated user with new profile picture
        final updatedUser = User(
          id: currentState.user.id,
          phoneNumber: currentState.user.phoneNumber,
          firstName: currentState.user.firstName,
          lastName: currentState.user.lastName,
          email: currentState.user.email,
          grade: currentState.user.grade,
          profilePicture: response['profilePicture'],
        );
        
        emit(ProfileLoaded(user: updatedUser, grades: currentState.grades));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
