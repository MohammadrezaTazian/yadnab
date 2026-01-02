import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:education_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:education_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:education_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:education_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:education_app/features/settings/presentation/bloc/settings_event.dart';
import 'package:education_app/core/routes/app_routes.dart';
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
  bool _otpSent = false;

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
          icon: Icon(
            Icons.settings_rounded,
            color: AppColors.onPrimary,
          ),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
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
            if (state is OtpSent) {
              setState(() => _otpSent = true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('کد تایید: ${state.otp}'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            } else if (state is AuthAuthenticated) {
              context.read<SettingsBloc>().add(LoadSettingsEvent());
              Navigator.of(context).pushReplacementNamed(AppRoutes.home);
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          },
          builder: (context, state) {
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
                            child: const Icon(
                              Icons.school_rounded,
                              size: 50,
                              color: AppColors.onPrimary,
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
                                border: Border.all(
                                  color: colorScheme.outline,
                                ),
                              ),
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: textTheme.bodyLarge,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context)!.phoneRequired;
                                  }
                                  final phoneRegex = RegExp(r'^09\d{9}$');
                                  if (!phoneRegex.hasMatch(value)) {
                                    return AppLocalizations.of(context)!.invalidPhone;
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.phone,
                                  hintText: '09121234567',
                                  hintStyle: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                  labelStyle: textTheme.bodyMedium,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
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

                          const SizedBox(height: 20),

                          if (_otpSent)
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
                                    defaultPinTheme: PinTheme(
                                      width: 56,
                                      height: 56,
                                      textStyle: textTheme.headlineMedium,
                                      decoration: BoxDecoration(
                                        color: colorScheme.surfaceContainerHighest,
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
                                        color: colorScheme.surfaceContainerHighest,
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
                                              _phoneController.text,
                                              pin,
                                            ),
                                          );
                                    },
                                  ),
                                ),
                              ],
                            ),

                          const SizedBox(height: 30),

                          // Button
                          ElevatedButton(
                            onPressed: () {
                              if (!_otpSent) {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthBloc>().add(
                                        SendOtpEvent(_phoneController.text),
                                      );
                                }
                              } else {
                                context.read<AuthBloc>().add(
                                      VerifyOtpEvent(
                                        _phoneController.text,
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
                            child: Text(
                              !_otpSent
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

