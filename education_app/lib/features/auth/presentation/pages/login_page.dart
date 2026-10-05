import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:education_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:education_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:education_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';
import 'package:education_app/l10n/app_localizations.dart';
import 'package:education_app/shared/theme/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();

    // گارد محافظتی: در صورتی که کاربر از قبل احراز هویت شده باشد، مستقیماً به خانه ریدایرکت شود
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.go('/home');
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.settings_rounded, color: AppColors.onPrimary),
          onPressed: () => context.push('/settings'),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.primaryGradientDark
              : AppColors.primaryGradientLight,
        ),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              context.go('/home');
            } else if (state is OtpState &&
                state.status == OtpStatus.error &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            final otpState = state is OtpState ? state : null;
            final otpVisible = otpState != null;

            if (state is AuthAuthenticated) {
              return const Center(child: CircularProgressIndicator());
            }

            return Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    elevation: 20,
                    color: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 450),
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: isDark
                                  ? AppColors.primaryGradientDark
                                  : AppColors.primaryGradientLight,
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logos/yadnab_logo.png',
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Phone Input
                          Form(
                            key: _formKey,
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: colorScheme.outline),
                              ),
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: textTheme.bodyLarge,
                                readOnly: otpVisible,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.phoneRequired;
                                  }
                                  final phoneRegex = RegExp(r'^09\d{9}$');
                                  if (!phoneRegex.hasMatch(value)) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.invalidPhone;
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(
                                    context,
                                  )!.phone,
                                  hintText: '09121234567',
                                  hintStyle: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  labelStyle: textTheme.bodyMedium,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(8),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.phone_rounded,
                                      color: AppColors.onPrimary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (otpVisible)
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton.icon(
                              onPressed: () {
                                _otpController.clear();

                                context.read<AuthBloc>().add(
                                  EditPhoneNumberEvent(),
                                );
                              },
                              icon: const Icon(Icons.edit_outlined),
                              label: Text(
                                AppLocalizations.of(context)!
                                    .editPhoneNumber,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          if (otpVisible)
                            Column(
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.otp,
                                  style: textTheme.titleMedium,
                                ),
                                const SizedBox(height: 16),
                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Pinput(
                                    controller: _otpController,
                                    length: 5,
                                    enabled:
                                        otpState.status != OtpStatus.verifying,
                                    defaultPinTheme: PinTheme(
                                      width: 56,
                                      height: 56,
                                      textStyle: textTheme.headlineMedium,
                                      decoration: BoxDecoration(
                                        color:
                                            colorScheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: colorScheme.outline,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    focusedPinTheme: PinTheme(
                                      width: 56,
                                      height: 56,
                                      textStyle: textTheme.headlineMedium,
                                      decoration: BoxDecoration(
                                        color:
                                            colorScheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: colorScheme.primary,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    onCompleted: (pin) {
                                      context.read<AuthBloc>().add(
                                        VerifyOtpEvent(
                                          _phoneController.text.trim(),
                                          pin,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),

                                if (otpState.status == OtpStatus.verifying)
                                  const CircularProgressIndicator()
                                else if (otpState.remainingSeconds > 0)
                                  Text(
                                    '00:${otpState.remainingSeconds.toString().padLeft(2, '0')}',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                else if (otpState.status ==
                                        OtpStatus.expired ||
                                    otpState.status == OtpStatus.error)
                                  TextButton(
                                    onPressed: () {
                                      context.read<AuthBloc>().add(
                                        ResendOtpEvent(
                                          _phoneController.text.trim(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!.resendCode,
                                    ),
                                  ),
                              ],
                            ),

                          const SizedBox(height: 30),

                          // Button
                          ElevatedButton(
                            onPressed:
                                otpState?.status == OtpStatus.sending ||
                                    otpState?.status == OtpStatus.verifying
                                ? null
                                : () {
                                    if (!otpVisible) {
                                      if (_formKey.currentState!.validate()) {
                                        context.read<AuthBloc>().add(
                                          SendOtpEvent(
                                            _phoneController.text.trim(),
                                          ),
                                        );
                                      }
                                    } else {
                                      context.read<AuthBloc>().add(
                                        VerifyOtpEvent(
                                          _phoneController.text.trim(),
                                          _otpController.text,
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child:
                                otpState?.status == OtpStatus.sending ||
                                    otpState?.status == OtpStatus.verifying
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    !otpVisible
                                        ? AppLocalizations.of(context)!.sendOtp
                                        : AppLocalizations.of(context)!.login,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
