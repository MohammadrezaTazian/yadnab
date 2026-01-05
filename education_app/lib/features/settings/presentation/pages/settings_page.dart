import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:education_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:education_app/features/settings/presentation/bloc/settings_event.dart';
import 'package:education_app/features/settings/presentation/bloc/settings_state.dart';
import 'package:education_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:education_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:education_app/l10n/app_localizations.dart';
import 'package:education_app/shared/widgets/app_drawer.dart';
import 'package:education_app/shared/theme/app_colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isAuthenticated = authState is AuthAuthenticated;
        return Scaffold(
          drawer: isAuthenticated ? const AppDrawer() : null,
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.settings,
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? AppColors.headerGradientDark
                    : AppColors.headerGradientLight,
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
            ),
            child: BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSectionTitle(context, AppLocalizations.of(context)!.appearance),
                    _buildSettingCard(
                      context,
                      children: [
                        SwitchListTile(
                          title: Text(
                            AppLocalizations.of(context)!.darkMode,
                            style: textTheme.bodyLarge,
                          ),
                          value: state.isDarkMode,
                          onChanged: (value) {
                            context.read<SettingsBloc>().add(ChangeThemeEvent(value));
                          },
                          secondary: Icon(
                            Icons.dark_mode_rounded,
                            color: colorScheme.primary,
                          ),
                          activeColor: colorScheme.primary,
                        ),
                        const Divider(),
                        ListTile(
                          title: Text(
                            AppLocalizations.of(context)!.fontSize,
                            style: textTheme.bodyLarge,
                          ),
                          subtitle: Slider(
                            value: state.fontSize,
                            min: 12.0,
                            max: 24.0,
                            divisions: 6,
                            label: state.fontSize.round().toString(),
                            activeColor: colorScheme.primary,
                            onChanged: (value) {
                              context.read<SettingsBloc>().add(ChangeFontSizeEvent(value));
                            },
                          ),
                          leading: Icon(
                            Icons.text_fields_rounded,
                            color: colorScheme.tertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, AppLocalizations.of(context)!.language),
                    _buildSettingCard(
                      context,
                      children: [
                        ListTile(
                          title: Text(
                            AppLocalizations.of(context)!.language,
                            style: textTheme.bodyLarge,
                          ),
                          leading: Icon(
                            Icons.language_rounded,
                            color: colorScheme.secondary,
                          ),
                          trailing: DropdownButton<String>(
                            value: state.languageCode,
                            dropdownColor: colorScheme.surfaceContainerHighest,
                            style: textTheme.bodyMedium,
                            items: const [
                              DropdownMenuItem(
                                value: 'fa',
                                child: Text('فارسی'),
                              ),
                              DropdownMenuItem(
                                value: 'en',
                                child: Text('English'),
                              ),
                            ],
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                context.read<SettingsBloc>().add(ChangeLanguageEvent(newValue));
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, AppLocalizations.of(context)!.reset),
                    _buildSettingCard(
                      context,
                      children: [
                        ListTile(
                          title: Text(
                            AppLocalizations.of(context)!.resetToDefault,
                            style: textTheme.bodyLarge,
                          ),
                          subtitle: Text(
                            AppLocalizations.of(context)!.resetDescription,
                            style: textTheme.bodySmall,
                          ),
                          leading: Icon(
                            Icons.restore_rounded,
                            color: AppColors.error,
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => _showResetDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: AppColors.onPrimary,
                            ),
                            child: Text(AppLocalizations.of(context)!.reset),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showResetDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
              ),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.confirmReset,
                style: textTheme.titleMedium,
              ),
            ],
          ),
          content: Text(
            AppLocalizations.of(context)!.resetConfirmMessage,
            style: textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<SettingsBloc>().add(const ChangeThemeEvent(false));
                context.read<SettingsBloc>().add(const ChangeLanguageEvent('fa'));
                context.read<SettingsBloc>().add(const ChangeFontSizeEvent(14.0));

                Navigator.of(dialogContext).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.resetSuccess),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.onPrimary,
              ),
              child: Text(AppLocalizations.of(context)!.reset),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
      ),
    );
  }

  Widget _buildSettingCard(BuildContext context, {required List<Widget> children}) {

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

