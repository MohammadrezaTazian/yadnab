import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:education_app/features/auth/domain/entities/user.dart';
import 'package:education_app/features/auth/domain/usecases/auth_usecases.dart';
import 'package:education_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:education_app/features/auth/presentation/bloc/auth_state.dart';

class _StartupUser extends User {
  const _StartupUser() : super(id: 0, phoneNumber: '');
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;

  Timer? _otpTimer;
  int _remainingSeconds = 0;
  String? _pendingOtp;
  int _otpRequestVersion = 0;

  AuthBloc({
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.logoutUseCase,
    required this.checkAuthStatusUseCase,
  }) : super(AuthInitial()) {
    on<SendOtpEvent>(_onSendOtp);
    on<ResendOtpEvent>(_onResendOtp);
    on<EditPhoneNumberEvent>(_onEditPhoneNumber);
    on<OtpTimerTickEvent>(_onOtpTimerTick);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<LogoutEvent>(_onLogout);
    on<AuthSessionExpiredEvent>(_onAuthSessionExpired);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onSendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    await _sendOtp(event.phoneNumber, emit);
  }

  Future<void> _onResendOtp(
    ResendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (_remainingSeconds > 0) {
      return;
    }

    await _sendOtp(event.phoneNumber, emit);
  }

  Future<void> _sendOtp(String phoneNumber, Emitter<AuthState> emit) async {
    final requestVersion = ++_otpRequestVersion;
    _pendingOtp = null;
    _startOtpTimer();

    emit(const OtpState(status: OtpStatus.sending, remainingSeconds: 60));

    try {
      final otp = await sendOtpUseCase(phoneNumber);

      if (isClosed || requestVersion != _otpRequestVersion) {
        return;
      }

      emit(
        OtpState(
          status: OtpStatus.ready,
          remainingSeconds: _remainingSeconds,
          otp: otp,
        ),
      );

      final pendingOtp = _pendingOtp;
      _pendingOtp = null;

      if (pendingOtp != null && pendingOtp.length == 5) {
        await _performVerifyOtp(phoneNumber, pendingOtp, emit);
      }
    } catch (e) {
      if (isClosed || requestVersion != _otpRequestVersion) {
        return;
      }

      _stopOtpTimer();
      _remainingSeconds = 0;
      _pendingOtp = null;

      emit(OtpState(status: OtpStatus.error, errorMessage: e.toString()));
    }
  }

  void _onEditPhoneNumber(EditPhoneNumberEvent event, Emitter<AuthState> emit) {
    _otpRequestVersion++;

    _stopOtpTimer();
    _remainingSeconds = 0;
    _pendingOtp = null;

    emit(AuthUnauthenticated());
  }

  void _startOtpTimer() {
    _otpTimer?.cancel();
    _remainingSeconds = 60;

    _otpTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isClosed) {
        add(OtpTimerTickEvent());
      }
    });
  }

  void _stopOtpTimer() {
    _otpTimer?.cancel();
    _otpTimer = null;
  }

  void _onOtpTimerTick(OtpTimerTickEvent event, Emitter<AuthState> emit) {
    if (_remainingSeconds <= 1) {
      _remainingSeconds = 0;
      _stopOtpTimer();

      if (state is OtpState) {
        final currentState = state as OtpState;

        emit(
          currentState.copyWith(status: OtpStatus.expired, remainingSeconds: 0),
        );
      }

      return;
    }

    _remainingSeconds--;

    if (state is OtpState) {
      final currentState = state as OtpState;

      emit(currentState.copyWith(remainingSeconds: _remainingSeconds));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (state is OtpState) {
      final otpState = state as OtpState;

      if (otpState.status == OtpStatus.sending) {
        _pendingOtp = event.otp;
        return;
      }

      if (otpState.status == OtpStatus.verifying) {
        return;
      }
    }

    await _performVerifyOtp(event.phoneNumber, event.otp, emit);
  }

  Future<void> _performVerifyOtp(
    String phoneNumber,
    String otp,
    Emitter<AuthState> emit,
  ) async {
    if (otp.length != 5) {
      return;
    }

    _stopOtpTimer();

    final currentOtpState = state is OtpState ? state as OtpState : null;

    emit(
      OtpState(
        status: OtpStatus.verifying,
        remainingSeconds:
            currentOtpState?.remainingSeconds ?? _remainingSeconds,
        otp: currentOtpState?.otp,
      ),
    );

    try {
      final user = await verifyOtpUseCase(phoneNumber, otp);

      if (isClosed) {
        return;
      }

      emit(AuthAuthenticated(user));
    } catch (e) {
      if (isClosed) {
        return;
      }

      final otpState = state is OtpState ? state as OtpState : null;

      emit(
        OtpState(
          status: OtpStatus.error,
          remainingSeconds: otpState?.remainingSeconds ?? _remainingSeconds,
          otp: otpState?.otp,
          errorMessage: e.toString(),
        ),
      );
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

  Future<void> _onAuthSessionExpired(
    AuthSessionExpiredEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthUnauthenticated());
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

  @override
  Future<void> close() {
    _stopOtpTimer();
    return super.close();
  }
}
