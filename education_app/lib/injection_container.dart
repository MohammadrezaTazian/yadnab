import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:education_app/shared/storage/shared_preferences_service.dart';
import 'package:education_app/shared/network/dio_client.dart';
import 'package:education_app/core/services/api_service.dart';
import 'package:education_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:education_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:education_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:education_app/features/auth/domain/usecases/auth_usecases.dart';
import 'package:education_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:education_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:education_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:education_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:education_app/features/profile/domain/usecases/profile_usecases.dart';
import 'package:education_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:education_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:education_app/features/course_topics/data/repositories/course_topic_repository_impl.dart';
import 'package:education_app/features/course_topics/domain/repositories/course_topic_repository.dart';
import 'package:education_app/features/course_topics/domain/usecases/get_course_topics.dart';
import 'package:education_app/features/course_topics/presentation/bloc/course_topic_bloc.dart';
import 'package:education_app/features/quiz/data/repositories/question_repository_impl.dart';
import 'package:education_app/features/quiz/domain/repositories/question_repository.dart';
import 'package:education_app/features/quiz/domain/usecases/get_questions_by_topic.dart';
import 'package:education_app/features/quiz/presentation/bloc/question_bloc.dart';
import 'package:education_app/features/education/data/repositories/education_content_repository_impl.dart';
import 'package:education_app/features/education/domain/repositories/education_content_repository.dart';
import 'package:education_app/features/education/domain/usecases/get_education_contents_by_topic.dart';
import 'package:education_app/features/education/presentation/bloc/education_content_bloc.dart';
import 'package:education_app/features/comment/data/repositories/comment_repository_impl.dart';
import 'package:education_app/features/comment/domain/repositories/comment_repository.dart';
import 'package:education_app/features/comment/domain/usecases/get_comments.dart';
import 'package:education_app/features/comment/domain/usecases/add_comment.dart';
import 'package:education_app/features/comment/domain/usecases/toggle_like.dart';
import 'package:education_app/features/comment/presentation/bloc/comment_bloc.dart';
import 'package:education_app/features/upload/data/datasources/upload_data_source.dart';
import 'package:education_app/features/upload/data/repositories/upload_repository_impl.dart';
import 'package:education_app/features/upload/presentation/bloc/upload_bloc.dart';
import 'package:education_app/features/upload/presentation/pages/image_upload_page.dart';  // Optional but safe
import 'package:education_app/core/config/config_service.dart';

final getIt = GetIt.instance;
final sl = getIt; // Alias for service locator

Future<void> setupDependencyInjection() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Core
  getIt.registerLazySingleton<SharedPreferencesService>(
    () => SharedPreferencesService(getIt()),
  );
  getIt.registerLazySingleton<DioClient>(() => DioClient());
  
  // API Service
  getIt.registerLazySingleton<ApiService>(
    () => ApiService(
      dio: getIt<DioClient>().dio,
      sharedPreferences: getIt(),
    ),
  );

  // Auth Feature
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      prefsService: getIt(),
    ),
  );
  getIt.registerLazySingleton(() => SendOtpUseCase(getIt()));
  getIt.registerLazySingleton(() => VerifyOtpUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));
  
  getIt.registerFactory(
    () => AuthBloc(
      sendOtpUseCase: getIt(),
      verifyOtpUseCase: getIt(),
      logoutUseCase: getIt(),
    ),
  );

  // Profile Feature
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSource(getIt<DioClient>().dio, getIt()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => GetProfileUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateProfileUseCase(getIt()));
  getIt.registerLazySingleton(() => GetGradesUseCase(getIt()));
  
  getIt.registerFactory(
    () => ProfileBloc(
      getProfileUseCase: getIt(),
      updateProfileUseCase: getIt(),
      getGradesUseCase: getIt(),
      apiService: getIt(),
    ),
  );

  // Settings Feature
  getIt.registerFactory(
    () => SettingsBloc(
      prefsService: getIt(),
      apiService: getIt(),
    ),
  );

  // Course Topics Feature
  getIt.registerLazySingleton<CourseTopicRepository>(
    () => CourseTopicRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => GetCourseTopics(getIt()));
  
  getIt.registerFactory(
    () => CourseTopicBloc(
      getCourseTopics: getIt(),
    ),
  );

  // Quiz Feature
  getIt.registerLazySingleton<QuestionRepository>(
    () => QuestionRepositoryImpl(apiService: getIt()),
  );
  getIt.registerLazySingleton(() => GetQuestionsByTopic(getIt()));
  
  getIt.registerFactory(
    () => QuestionBloc(
      getQuestionsByTopic: getIt(),
    ),
  );

  // Education Feature
  getIt.registerLazySingleton<EducationContentRepository>(
    () => EducationContentRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => GetEducationContentsByTopic(getIt()));
  
  getIt.registerFactory(
    () => EducationContentBloc(
      getEducationContentsByTopic: getIt(),
      toggleLike: getIt(),
    ),
  );
  // Comment Feature
  getIt.registerLazySingleton<CommentRepository>(
    () => CommentRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => GetComments(getIt()));
  getIt.registerLazySingleton(() => AddComment(getIt()));
  // ToggleLike might be needed for LikeButton or CommentBloc if integrated, 
  // currently LikeButton might use a separate Bloc or just this usecase.
  // Let's register it.
  getIt.registerLazySingleton(() => ToggleLike(getIt())); 

  getIt.registerFactory(
    () => CommentBloc(
      getComments: getIt(),
      addComment: getIt(),
      commentRepository: getIt(),
      toggleLike: getIt(),
    ),
  );

  // Upload Feature
  getIt.registerLazySingleton<UploadDataSource>(
    () => UploadDataSourceImpl(
      client: getIt<DioClient>().dio,
      configService: ConfigService(),
    ),
  );
  getIt.registerLazySingleton<UploadRepository>(
    () => UploadRepositoryImpl(getIt()),
  );
  getIt.registerFactory(
    () => UploadBloc(repository: getIt()),
  );
}
