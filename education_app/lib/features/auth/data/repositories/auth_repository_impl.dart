import 'package:education_app/core/constants/storage_constants.dart';
import 'package:education_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:education_app/features/auth/domain/entities/user.dart';
import 'package:education_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:education_app/shared/storage/shared_preferences_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SharedPreferencesService prefsService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.prefsService,
  });

  @override
  Future<String> sendOtp(String phoneNumber) async {
    return await remoteDataSource.sendOtp(phoneNumber);
  }

  @override
  Future<User> verifyOtp(String phoneNumber, String otp) async {
    final userModel = await remoteDataSource.verifyOtp(phoneNumber, otp);
    
    // Save tokens
    await prefsService.setString(StorageConstants.accessToken, userModel.accessToken);
    await prefsService.setString(StorageConstants.refreshToken, userModel.refreshToken);
    await prefsService.setInt(StorageConstants.userId, userModel.id);
    await prefsService.setString(StorageConstants.phoneNumber, userModel.phoneNumber);
    
    return userModel;
  }

  @override
  Future<User> refreshToken(String refreshToken) async {
    final userModel = await remoteDataSource.refreshToken(refreshToken);
    
    // Update tokens
    await prefsService.setString(StorageConstants.accessToken, userModel.accessToken);
    await prefsService.setString(StorageConstants.refreshToken, userModel.refreshToken);
    
    return userModel;
  }

  @override
  Future<void> logout() async {
    await prefsService.remove(StorageConstants.accessToken);
    await prefsService.remove(StorageConstants.refreshToken);
    await prefsService.remove(StorageConstants.userId);
    await prefsService.remove(StorageConstants.phoneNumber);
  }
}
