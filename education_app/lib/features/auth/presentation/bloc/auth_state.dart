import 'package:equatable/equatable.dart';
import 'package:education_app/features/auth/domain/entities/user.dart';

enum OtpStatus { sending, ready, verifying, expired, error }

class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpState extends AuthState {
  final OtpStatus status;
  final int remainingSeconds;
  final String? otp;
  final String? errorMessage;

  const OtpState({
    required this.status,
    this.remainingSeconds = 0,
    this.otp,
    this.errorMessage,
  });

  OtpState copyWith({
    OtpStatus? status,
    int? remainingSeconds,
    String? otp,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OtpState(
      status: status ?? this.status,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      otp: otp ?? this.otp,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, remainingSeconds, otp, errorMessage];
}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
