import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:education_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:education_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:education_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:education_app/features/profile/domain/entities/grade.dart';
import 'package:education_app/features/auth/domain/entities/user.dart';
import 'package:education_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:education_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:education_app/core/routes/app_routes.dart';
import 'package:education_app/l10n/app_localizations.dart';
import 'package:education_app/shared/widgets/app_drawer.dart';
import 'package:education_app/shared/theme/app_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  String? _selectedGrade;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    context.read<ProfileBloc>().add(LoadProfileEvent());
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _updateControllers(User user) {
    _firstNameController.text = user.firstName ?? '';
    _lastNameController.text = user.lastName ?? '';
    _emailController.text = user.email ?? '';
    _selectedGrade = (user.grade != null && user.grade!.isNotEmpty) ? user.grade : null;
  }

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.loading),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      if (context.mounted) {
        context.read<ProfileBloc>().add(UpdateProfilePictureEvent(base64Image));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutEvent());
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
        ),
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoaded) {
              _updateControllers(state.user);
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            } else if (state is ProfileUpdating) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.loading),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProfileLoaded || state is ProfileUpdated) {
              final user = (state is ProfileLoaded)
                  ? state.user
                  : (state as ProfileUpdated).user;

              if (_firstNameController.text.isEmpty && (user.firstName ?? '').isNotEmpty) {
                _updateControllers(user);
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Profile Picture
                            Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: isDark
                                        ? AppColors.primaryGradientDark
                                        : AppColors.primaryGradientLight,
                                  ),
                                  child: Container(
                                    width: 130,
                                    height: 130,
                                    decoration: BoxDecoration(
                                      color: colorScheme.surface,
                                      shape: BoxShape.circle,
                                    ),
                                    child: ClipOval(
                                      child: user.profilePicture != null && user.profilePicture!.isNotEmpty
                                          ? Image.memory(
                                              const Base64Decoder().convert(user.profilePicture!),
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.person_rounded,
                                                  size: 60,
                                                  color: colorScheme.primary,
                                                );
                                              },
                                            )
                                          : Icon(
                                              Icons.person_rounded,
                                              size: 60,
                                              color: colorScheme.primary,
                                            ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => _pickAndUploadImage(context),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: isDark
                                            ? AppColors.primaryGradientDark
                                            : AppColors.primaryGradientLight,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: colorScheme.surface,
                                          width: 3,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.camera_alt_rounded,
                                        size: 20,
                                        color: AppColors.onPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Phone Number Display
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: colorScheme.primary.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.phone_rounded,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    user.phoneNumber,
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                    textDirection: TextDirection.ltr,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Form Fields
                            _buildProfileField(
                              context,
                              controller: _firstNameController,
                              icon: Icons.person_outline_rounded,
                              label: AppLocalizations.of(context)!.firstName,
                              hint: AppLocalizations.of(context)!.enterFirstName,
                              iconColor: colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            _buildProfileField(
                              context,
                              controller: _lastNameController,
                              icon: Icons.family_restroom_rounded,
                              label: AppLocalizations.of(context)!.lastName,
                              hint: AppLocalizations.of(context)!.enterLastName,
                              iconColor: colorScheme.secondary,
                            ),
                            const SizedBox(height: 16),
                            _buildProfileField(
                              context,
                              controller: _emailController,
                              icon: Icons.email_outlined,
                              label: AppLocalizations.of(context)!.email,
                              hint: AppLocalizations.of(context)!.enterEmail,
                              iconColor: AppColors.accentLight,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return null;
                                }
                                final emailRegex = RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                );
                                if (!emailRegex.hasMatch(value)) {
                                  return AppLocalizations.of(context)!.invalidEmail;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildGradeDropdown(
                              context,
                              (state is ProfileLoaded)
                                  ? state.grades
                                  : (state as ProfileUpdated).grades,
                            ),
                            const SizedBox(height: 32),
                            
                            // Save Button
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<ProfileBloc>().add(
                                          UpdateProfileEvent(
                                            firstName: _firstNameController.text,
                                            lastName: _lastNameController.text,
                                            email: _emailController.text,
                                            grade: _selectedGrade,
                                          ),
                                        );
                                  }
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.saveChanges,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildProfileField(
    BuildContext context, {
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String hint,
    required Color iconColor,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.onPrimary, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildGradeDropdown(BuildContext context, List<Grade> grades) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final gradeNames = grades.map((g) => g.name).toList();
    final validSelectedGrade = (_selectedGrade != null && gradeNames.contains(_selectedGrade))
        ? _selectedGrade
        : null;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: validSelectedGrade,
        dropdownColor: colorScheme.surface,
        style: textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.grade,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.school_rounded, color: AppColors.onPrimary, size: 20),
          ),
        ),
        items: grades.map((Grade grade) {
          return DropdownMenuItem<String>(
            value: grade.name,
            child: Text(grade.name),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedGrade = newValue;
          });
        },
      ),
    );
  }
}

