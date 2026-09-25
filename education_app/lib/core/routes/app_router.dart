import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:education_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:education_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:education_app/features/auth/presentation/pages/login_page.dart';
import 'package:education_app/features/settings/presentation/pages/settings_page.dart';
import 'package:education_app/features/upload/presentation/pages/image_upload_page.dart';
import 'package:education_app/shared/widgets/main_navigation.dart';
import 'package:education_app/features/topics/presentation/pages/topics_page.dart';
import 'package:education_app/features/education/presentation/pages/education_content_list_page.dart';
import 'package:education_app/features/education/presentation/pages/education_content_detail_page.dart';
import 'package:education_app/features/quiz/presentation/pages/quiz_list_page.dart';
import 'package:education_app/features/quiz/presentation/pages/question_detail_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:education_app/core/utils/url_helper.dart';
import 'package:education_app/injection_container.dart';
import 'package:education_app/shared/widgets/dio_network_svg_image.dart';
import 'package:education_app/features/education/presentation/bloc/education_content_bloc.dart';
import 'package:education_app/features/education/domain/entities/education_content.dart';
import 'package:education_app/features/education/data/models/education_content_model.dart';
import 'package:education_app/features/quiz/domain/entities/question.dart';
import 'package:education_app/features/quiz/data/models/question_model.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  static GoRouter? _router;

  static GoRouter get router => _router ??= _createRouter();

  static GoRouter createRouter(BuildContext? context) => router;

  static GoRouter _createRouter() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      debugLogDiagnostics: false,
      initialLocation: '/splash',
      redirect: (context, state) {
        // Auth is managed inside AuthGateScreen
        return null;
      },
      routes: [
        // =================== Splash / Auth Gate ===================
        GoRoute(
          path: '/splash',
          builder: (context, state) => const AuthGateScreen(),
        ),

        // =================== Auth ===================
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),

        // =================== Main App (Home with bottom nav) ===================
        GoRoute(
          path: '/home',
          builder: (context, state) => const MainNavigationPage(),
        ),

        // =================== Settings ===================
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),

        // =================== Upload ===================
        GoRoute(
          path: '/upload',
          builder: (context, state) => const ImageUploadPage(),
        ),

        // =================== Topics ===================
        GoRoute(
          path: '/topics',
          builder: (context, state) {
            final extra = state.extra is Map<String, dynamic> ? state.extra as Map<String, dynamic> : null;
            final packageIdStr = state.uri.queryParameters['packageId'];
            final packageId = extra?['packageId'] as int? ?? (packageIdStr != null ? int.tryParse(packageIdStr) : null) ?? 0;
            final title = extra?['title'] as String? ?? state.uri.queryParameters['title'] ?? 'سرفصل‌ها';
            return TopicsPage(
              packageId: packageId,
              title: title,
            );
          },
        ),

        // =================== Education Content List ===================
        GoRoute(
          path: '/education-content',
          builder: (context, state) {
            final extra = state.extra is Map<String, dynamic> ? state.extra as Map<String, dynamic> : null;
            final topicIdStr = state.uri.queryParameters['topicId'];
            final topicId = extra?['topicId'] as int? ?? (topicIdStr != null ? int.tryParse(topicIdStr) : null) ?? 0;
            final topicTitle = extra?['topicTitle'] as String? ?? state.uri.queryParameters['topicTitle'] ?? 'محتوای آموزشی';
            final packageIdStr = state.uri.queryParameters['packageId'];
            final packageId = extra?['packageId'] as int? ?? (packageIdStr != null ? int.tryParse(packageIdStr) : null);
            final packageTitle = extra?['packageTitle'] as String? ?? state.uri.queryParameters['packageTitle'];
            return EducationContentListPage(
              topicId: topicId,
              topicTitle: topicTitle,
              packageId: packageId,
              packageTitle: packageTitle,
            );
          },
        ),

        // =================== Education Content Detail ===================
        GoRoute(
          path: '/education-content-detail',
          builder: (context, state) {
            final extra = state.extra is Map<String, dynamic> ? state.extra as Map<String, dynamic> : null;
            final rawContent = extra?['content'];
            EducationContent? content;
            if (rawContent is EducationContent) {
              content = rawContent;
            } else if (rawContent is Map) {
              try {
                content = EducationContentModel.fromJson(Map<String, dynamic>.from(rawContent));
              } catch (e) {
                debugPrint('Error parsing EducationContent from extra: $e');
              }
            }
            final bloc = extra?['bloc'] as EducationContentBloc?;

            if (content == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('محتوای آموزشی')),
                body: const Center(
                  child: Text('اطلاعات محتوا در دسترس نیست. لطفاً از لیست مطالب وارد شوید.'),
                ),
              );
            }

            if (bloc != null) {
              return BlocProvider<EducationContentBloc>.value(
                value: bloc,
                child: EducationContentDetailPage(content: content),
              );
            }

            return BlocProvider<EducationContentBloc>(
              create: (context) => sl<EducationContentBloc>(),
              child: EducationContentDetailPage(content: content),
            );
          },
        ),

        // =================== Quiz List ===================
        GoRoute(
          path: '/quiz-list',
          builder: (context, state) {
            final extra = state.extra is Map<String, dynamic> ? state.extra as Map<String, dynamic> : null;
            final topicIdStr = state.uri.queryParameters['topicId'];
            final topicId = extra?['topicId'] as int? ?? (topicIdStr != null ? int.tryParse(topicIdStr) : null) ?? 0;
            final topicTitle = extra?['topicTitle'] as String? ?? state.uri.queryParameters['topicTitle'] ?? 'لیست آزمون';
            final packageIdStr = state.uri.queryParameters['packageId'];
            final packageId = extra?['packageId'] as int? ?? (packageIdStr != null ? int.tryParse(packageIdStr) : null);
            final packageTitle = extra?['packageTitle'] as String? ?? state.uri.queryParameters['packageTitle'];
            return QuizListPage(
              topicId: topicId,
              topicTitle: topicTitle,
              packageId: packageId,
              packageTitle: packageTitle,
            );
          },
        ),

        // =================== Question Detail ===================
        GoRoute(
          path: '/question-detail',
          builder: (context, state) {
            final extra = state.extra is Map<String, dynamic> ? state.extra as Map<String, dynamic> : null;
            final rawQuestion = extra?['question'];
            Question? question;
            if (rawQuestion is Question) {
              question = rawQuestion;
            } else if (rawQuestion is Map) {
              try {
                question = QuestionModel.fromJson(Map<String, dynamic>.from(rawQuestion));
              } catch (e) {
                debugPrint('Error parsing Question from extra: $e');
              }
            }
            final rawIndex = extra?['index'];
            final index = (rawIndex is num)
                ? rawIndex.toInt()
                : (rawIndex != null ? int.tryParse('$rawIndex') ?? 1 : 1);

            if (question == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('سوال')),
                body: const Center(
                  child: Text('اطلاعات سوال در دسترس نیست. لطفاً از لیست سوالات وارد شوید.'),
                ),
              );
            }

            return QuestionDetailPage(
              question: question,
              index: index,
            );
          },
        ),

        // =================== Image Viewer ===================
        GoRoute(
          path: '/image-viewer',
          builder: (context, state) {
            final extra = state.extra is Map<String, dynamic> ? state.extra as Map<String, dynamic> : null;
            final imageUrl = extra?['imageUrl'] as String? ?? state.uri.queryParameters['imageUrl'] ?? '';
            final title = extra?['title'] as String? ?? state.uri.queryParameters['title'] ?? 'تصویر';
            return _ImageViewerPage(imageUrl: imageUrl, title: title);
          },
        ),
      ],
      errorBuilder: (context, state) => const MainNavigationPage(),
    );
  }
}

/// صفحه دروازه احراز هویت در استارتاپ
class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authState = context.read<AuthBloc>().state;
      _navigateByState(authState);
    });
  }

  void _navigateByState(AuthState authState) {
    if (!mounted) return;
    if (authState is AuthAuthenticated) {
      context.go('/home');
    } else if (authState is AuthUnauthenticated || authState is AuthError) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) => _navigateByState(state),
      child: const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

/// Image Viewer صفحه داخلی
class _ImageViewerPage extends StatelessWidget {
  final String imageUrl;
  final String title;

  const _ImageViewerPage({required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title, style: const TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          scaleEnabled: true,
          minScale: 0.5,
          maxScale: 5.0,
          child: _buildImage(context, imageUrl),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, String path) {
    if (path.isEmpty) {
      return const Icon(Icons.broken_image, color: Colors.white, size: 60);
    }
    final resolved = path.startsWith('assets/') ? path : UrlHelper.resolve(path);
    final isSvg = resolved.toLowerCase().endsWith('.svg');
    final isNetwork = resolved.toLowerCase().startsWith('http');

    if (isNetwork) {
      if (isSvg) {
        return DioNetworkSvgImage(
          imageUrl: resolved,
          height: MediaQuery.of(context).size.height * 0.75,
        );
      }
      return Image.network(
        resolved,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        },
        errorBuilder: (context, error, stack) =>
            const Icon(Icons.broken_image, color: Colors.white, size: 60),
      );
    } else {
      if (isSvg) {
        return SvgPicture.asset(
          path,
          height: MediaQuery.of(context).size.height * 0.75,
        );
      }
      return Image.asset(path, fit: BoxFit.contain);
    }
  }
}
