import 'package:flutter/material.dart';
import 'package:education_app/l10n/app_localizations.dart';
import 'package:education_app/shared/widgets/main_navigation.dart';
import 'package:education_app/shared/theme/app_colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: Column(
        children: [
          // Drawer Header with Gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            decoration: BoxDecoration(
              gradient: isDark
                  ? AppColors.headerGradientDark
                  : AppColors.headerGradientLight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.onPrimary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    size: 48,
                    color: AppColors.onPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  t?.appTitle ?? 'Education App',
                  style: TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'بهترین راه یادگیری',
                  style: TextStyle(
                    color: AppColors.onPrimary.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.home_rounded,
                  title: t?.home ?? 'خانه',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MainNavigationPage()),
                      (route) => false,
                    );
                  },
                ),
                _buildNavItem(
                  context,
                  icon: Icons.person_rounded,
                  title: t?.profile ?? 'پروفایل',
                  onTap: () {
                    Navigator.pop(context);
                    final mainNav = context.findAncestorStateOfType<MainNavigationPageState>();
                    mainNav?.navigateToIndex(1);
                  },
                ),
                _buildNavItem(
                  context,
                  icon: Icons.settings_rounded,
                  title: t?.settings ?? 'تنظیمات',
                  onTap: () {
                    Navigator.pop(context);
                    final mainNav = context.findAncestorStateOfType<MainNavigationPageState>();
                    mainNav?.navigateToIndex(2);
                  },
                ),
                const Divider(height: 32),
                _buildNavItem(
                  context,
                  icon: Icons.help_outline_rounded,
                  title: 'راهنما',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to help page
                  },
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'نسخه 1.0.0',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: colorScheme.primary,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hoverColor: colorScheme.primary.withValues(alpha: 0.08),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}

