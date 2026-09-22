import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:education_app/features/auth/domain/entities/user.dart';
import 'package:education_app/features/auth/domain/usecases/auth_usecases.dart';
import 'package:education_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:education_app/features/auth/presentation/bloc/auth_state.dart';

// User موقت برای startup check (وقتی token معتبر است ولی user object نداریم)
class _StartupUser extends User {
  const _StartupUser()
      : super(
          id: 0,
          phoneNumber: '',
        );
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;

  AuthBloc({
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.logoutUseCase,
    required this.checkAuthStatusUseCase,
  }) : super(AuthInitial()) {
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onSendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final otp = await sendOtpUseCase(event.phoneNumber);
      emit(OtpSent(otp));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyOtp(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await verifyOtpUseCase(event.phoneNumber, event.otp);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      await logoutUseCase();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final isAuthenticated = await checkAuthStatusUseCase();
      if (isAuthenticated) {
        emit(const AuthAuthenticated(_StartupUser()));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }
}
