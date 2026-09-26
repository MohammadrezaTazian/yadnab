import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:education_app/features/home/presentation/pages/home_page.dart';
import 'package:education_app/features/profile/presentation/pages/profile_page.dart';
import 'package:education_app/features/settings/presentation/pages/settings_page.dart';
import 'package:education_app/l10n/app_localizations.dart';

class MainNavigationPage extends StatelessWidget {
  const MainNavigationPage({super.key});

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    switch (location) {
      case '/profile':
        return 1;
      case '/settings':
        return 2;
      case '/home':
      default:
        return 0;
    }
  }

  Widget _getCurrentPage(int index) {
    switch (index) {
      case 1:
        return const ProfilePage();
      case 2:
        return const SettingsPage();
      case 0:
      default:
        return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIndex = _getCurrentIndex(context);

    return Scaffold(
      body: _getCurrentPage(currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/profile');
              break;
            case 2:
              context.go('/settings');
              break;
          }
        },
        backgroundColor: isDark ? const Color(0xFF1A1F3A) : null,
        selectedItemColor: isDark ? const Color(0xFF6C63FF) : null,
        unselectedItemColor: isDark ? const Color(0xFFB8B8CC) : null,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: AppLocalizations.of(context)!.profile,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: AppLocalizations.of(context)!.settings,
          ),
        ],
      ),
    );
  }
}

