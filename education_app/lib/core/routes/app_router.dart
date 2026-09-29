import 'package:education_app/features/quiz/presentation/bloc/question_bloc.dart';
import 'package:education_app/features/quiz/presentation/bloc/question_event.dart';
import 'package:education_app/features/quiz/presentation/bloc/question_state.dart';
import 'package:education_app/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:education_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:education_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:education_app/features/auth/presentation/pages/login_page.dart';
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
import 'dart:async';

class AuthRouterRefresh extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  AuthRouterRefresh(AuthBloc authBloc) {
    _subscription = authBloc.stream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'root',
  );

  static GoRouter? _router;
  static AuthRouterRefresh? _authRouterRefresh;

  static GoRouter createRouter(BuildContext context) {
    if (_router != null) {
      return _router!;
    }

    final authBloc = context.read<AuthBloc>();
    _authRouterRefresh = AuthRouterRefresh(authBloc);

    _router = _createRouter(authBloc);

    return _router!;
  }

  static GoRouter get router {
    if (_router == null) {
      throw StateError(
        'AppRouter has not been initialized. '
        'Call AppRouter.createRouter(context) first.',
      );
    }

    return _router!;
  }

  static GoRouter _createRouter(AuthBloc authBloc) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      debugLogDiagnostics: true,
      initialLocation: '/splash',
      refreshListenable: _authRouterRefresh,

      redirect: (context, state) {
        final authState = authBloc.state;
        final location = state.matchedLocation;

        debugPrint(
          '>>> ROUTER REDIRECT | uri=${state.uri} | matched=$location | auth=${authState.runtimeType}',
        );

        final isSplash = location == '/splash';
        final isLogin = location == '/login';
        final isSettings = location == '/settings';

        // فقط وضعیت اولیه برنامه باید روی Splash بماند.
        // AuthLoading ممکن است هنگام SendOtp یا VerifyOtp نیز رخ دهد
        // و نباید باعث Navigation به Splash شود.
        if (authState is AuthInitial) {
          return isSplash ? null : '/splash';
        }

        if (authState is AuthLoading) {
          return null;
        }

        // کاربر احراز هویت شده نباید بتواند وارد Login یا Splash شود.
        if (authState is AuthAuthenticated) {
          if (isSplash || isLogin) {
            return '/home';
          }

          return null;
        }

        // کاربر احراز هویت نشده فقط اجازه ورود به Login را دارد.
        if (authState is AuthUnauthenticated || authState is AuthError) {
          if (isLogin || isSettings) {
            return null;
          }

          return '/login';
        }

        return null;
      },

      routes: [
        // =================== Splash / Auth Gate ===================
        GoRoute(
          path: '/splash',
          builder: (context, state) => const AuthGateScreen(),
        ),

        // =================== Auth ===================
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),

        // =================== Main App (Home with bottom nav) ===================
        GoRoute(
          path: '/home',
          builder: (context, state) => const MainNavigationPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const MainNavigationPage(),
        ),
        // =================== Settings ===================
        GoRoute(
          path: '/settings',
          builder: (context, state) {
            final isAuthenticated = authBloc.state is AuthAuthenticated;

            return isAuthenticated
                ? const MainNavigationPage()
                : const SettingsPage();
          },
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
            final extra = state.extra is Map<String, dynamic>
                ? state.extra as Map<String, dynamic>
                : null;

            final packageIdStr = state.uri.queryParameters['packageId'];

            final packageId =
                extra?['packageId'] as int? ??
                (packageIdStr != null ? int.tryParse(packageIdStr) : null) ??
                0;

            final title =
                extra?['title'] as String? ??
                state.uri.queryParameters['title'] ??
                'سر فصل‌ها';

            return TopicsPage(packageId: packageId, title: title);
          },
        ),

        // =================== Education Content List ===================
        GoRoute(
          path: '/education-content',
          builder: (context, state) {
            final extra = state.extra is Map<String, dynamic>
                ? state.extra as Map<String, dynamic>
                : null;

            final topicIdStr = state.uri.queryParameters['topicId'];

            final topicId =
                extra?['topicId'] as int? ??
                (topicIdStr != null ? int.tryParse(topicIdStr) : null) ??
                0;

            final topicTitle =
                extra?['topicTitle'] as String? ??
                state.uri.queryParameters['topicTitle'] ??
                'محتوای آموزشی';

            final packageIdStr = state.uri.queryParameters['packageId'];

            final packageId =
                extra?['packageId'] as int? ??
                (packageIdStr != null ? int.tryParse(packageIdStr) : null);

            final packageTitle =
                extra?['packageTitle'] as String? ??
                state.uri.queryParameters['packageTitle'];

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
            final extra = state.extra is Map<String, dynamic>
                ? state.extra as Map<String, dynamic>
                : null;

            final rawContent = extra?['content'];

            EducationContent? content;

            if (rawContent is EducationContent) {
              content = rawContent;
            } else if (rawContent is Map) {
              try {
                content = EducationContentModel.fromJson(
                  Map<String, dynamic>.from(rawContent),
                );
              } catch (e) {
                debugPrint('Error parsing EducationContent from extra: $e');
              }
            }

            final bloc = extra?['bloc'] as EducationContentBloc?;

            final contentIdStr = state.uri.queryParameters['contentId'];

            final contentId = contentIdStr != null
                ? int.tryParse(contentIdStr)
                : null;

            final topicIdStr = state.uri.queryParameters['topicId'];

            final topicId = topicIdStr != null
                ? int.tryParse(topicIdStr)
                : null;

            final topicTitle =
                extra?['topicTitle'] as String? ??
                state.uri.queryParameters['topicTitle'];

            final packageIdStr = state.uri.queryParameters['packageId'];

            final packageId =
                extra?['packageId'] as int? ??
                (packageIdStr != null ? int.tryParse(packageIdStr) : null);

            final packageTitle =
                extra?['packageTitle'] as String? ??
                state.uri.queryParameters['packageTitle'];

            debugPrint(
              'EducationContentDetail route: '
              'contentId=$contentId, topicId=$topicId',
            );

            // Normal navigation: content is already available.
            if (content != null) {
              if (bloc != null) {
                return BlocProvider<EducationContentBloc>.value(
                  value: bloc,
                  child: EducationContentDetailPage(
                    content: content,
                    topicId: topicId,
                    topicTitle: topicTitle,
                    packageId: packageId,
                    packageTitle: packageTitle,
                  ),
                );
              }

              return BlocProvider<EducationContentBloc>(
                create: (_) => sl<EducationContentBloc>(),
                child: EducationContentDetailPage(
                  content: content,
                  topicId: topicId,
                  topicTitle: topicTitle,
                  packageId: packageId,
                  packageTitle: packageTitle,
                ),
              );
            }

            // Refresh/direct URL navigation.
            if (contentId != null && contentId > 0) {
              if (bloc != null) {
                return BlocProvider<EducationContentBloc>.value(
                  value: bloc,
                  child: EducationContentDetailPage(
                    contentId: contentId,
                    topicId: topicId,
                    topicTitle: topicTitle,
                    packageId: packageId,
                    packageTitle: packageTitle,
                  ),
                );
              }

              return BlocProvider<EducationContentBloc>(
                create: (_) => sl<EducationContentBloc>(),
                child: EducationContentDetailPage(
                  contentId: contentId,
                  topicId: topicId,
                  topicTitle: topicTitle,
                  packageId: packageId,
                  packageTitle: packageTitle,
                ),
              );
            }

            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  '\u0645\u062d\u062a\u0648\u0627\u06cc \u0622\u0645\u0648\u0632\u0634\u06cc',
                ),
              ),
              body: const Center(
                child: Text(
                  '\u0627\u0637\u0644\u0627\u0639\u0627\u062a \u0645\u062d\u062a\u0648\u0627 \u062f\u0631 \u062f\u0633\u062a\u0631\u0633 \u0646\u06cc\u0633\u062a.',
                ),
              ),
            );
          },
        ),
        // =================== Quiz List ===================
        GoRoute(
          path: '/quiz-list',
          builder: (context, state) {
            final extra = state.extra is Map<String, dynamic>
                ? state.extra as Map<String, dynamic>
                : null;

            final topicIdStr = state.uri.queryParameters['topicId'];

            final topicId =
                extra?['topicId'] as int? ??
                (topicIdStr != null ? int.tryParse(topicIdStr) : null) ??
                0;

            final topicTitle =
                extra?['topicTitle'] as String? ??
                state.uri.queryParameters['topicTitle'] ??
                'لیست آزمون';

            final packageIdStr = state.uri.queryParameters['packageId'];

            final packageId =
                extra?['packageId'] as int? ??
                (packageIdStr != null ? int.tryParse(packageIdStr) : null);

            final packageTitle =
                extra?['packageTitle'] as String? ??
                state.uri.queryParameters['packageTitle'];

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
            final extra = state.extra is Map<String, dynamic>
                ? state.extra as Map<String, dynamic>
                : null;

            // Essential state comes from the URL.
            final questionIdStr = state.uri.queryParameters['questionId'];
            final topicIdStr = state.uri.queryParameters['topicId'];

            final questionId = questionIdStr != null
                ? int.tryParse(questionIdStr)
                : null;

            final topicId = topicIdStr != null
                ? int.tryParse(topicIdStr)
                : null;

            // Optional optimization: use the Question object from extra
            // when navigating normally. On refresh, extra is unavailable
            // and QuestionDetailPage loads the question by ID.
            final rawQuestion = extra?['question'];

            Question? question;

            if (rawQuestion is Question) {
              question = rawQuestion;
            } else if (rawQuestion is Map) {
              try {
                question = QuestionModel.fromJson(
                  Map<String, dynamic>.from(rawQuestion),
                );
              } catch (e) {
                debugPrint('Error parsing Question from extra: $e');
              }
            }

            final rawIndex = extra?['index'];

            final index = (rawIndex is num)
                ? rawIndex.toInt()
                : (rawIndex != null ? int.tryParse('$rawIndex') ?? 1 : 1);

            final topicTitle =
                extra?['topicTitle'] as String? ??
                state.uri.queryParameters['topicTitle'];

            final packageIdStr = state.uri.queryParameters['packageId'];

            final packageId =
                extra?['packageId'] as int? ??
                (packageIdStr != null ? int.tryParse(packageIdStr) : null);

            final packageTitle =
                extra?['packageTitle'] as String? ??
                state.uri.queryParameters['packageTitle'];

            // questionId and topicId are required for a refresh-safe URL.
            if (questionId == null || topicId == null || topicId <= 0) {
              return Scaffold(
                appBar: AppBar(title: const Text('سوال')),
                body: const Center(
                  child: Text('شناسه سوال یا سرفصل معتبر نیست.'),
                ),
              );
            }

            return QuestionDetailPage(
              question: question,
              questionId: questionId,
              index: index,
              topicId: topicId,
              topicTitle: topicTitle,
              packageId: packageId,
              packageTitle: packageTitle,
            );
          },
        ),

        // =================== Image Viewer ===================
        GoRoute(
          path: '/image-viewer',
          builder: (context, state) {
            final extra = state.extra is Map<String, dynamic>
                ? state.extra as Map<String, dynamic>
                : null;

            final questionIdStr = state.uri.queryParameters['questionId'];

            final topicIdStr = state.uri.queryParameters['topicId'];

            final questionId = questionIdStr != null
                ? int.tryParse(questionIdStr)
                : null;

            final topicId = topicIdStr != null
                ? int.tryParse(topicIdStr)
                : null;

            final imageType =
                state.uri.queryParameters['imageType'] ?? 'question';

            final imageUrl =
                extra?['imageUrl'] as String? ??
                state.uri.queryParameters['imageUrl'] ??
                '';

            final title =
                extra?['title'] as String? ??
                state.uri.queryParameters['title'] ??
                'تصویر';

            final rawQuestion = extra?['question'];

            Question? question;

            if (rawQuestion is Question) {
              question = rawQuestion;
            } else if (rawQuestion is Map) {
              try {
                question = QuestionModel.fromJson(
                  Map<String, dynamic>.from(rawQuestion),
                );
              } catch (e) {
                debugPrint(
                  'Error parsing Question from image viewer extra: $e',
                );
              }
            }

            final rawIndex = extra?['index'];

            final index = (rawIndex is num)
                ? rawIndex.toInt()
                : (rawIndex != null ? int.tryParse('$rawIndex') ?? 1 : 1);

            final topicTitle =
                extra?['topicTitle'] as String? ??
                state.uri.queryParameters['topicTitle'];

            final packageIdStr = state.uri.queryParameters['packageId'];

            final packageId =
                extra?['packageId'] as int? ??
                (packageIdStr != null ? int.tryParse(packageIdStr) : null);

            final packageTitle =
                extra?['packageTitle'] as String? ??
                state.uri.queryParameters['packageTitle'];

            return _ImageViewerPage(
              imageUrl: imageUrl,
              title: title,
              question: question,
              questionId: questionId,
              topicId: topicId,
              imageType: imageType,
              index: index,
              topicTitle: topicTitle,
              packageId: packageId,
              packageTitle: packageTitle,
            );
          },
        ),
      ],

      errorBuilder: (context, state) => const MainNavigationPage(),
    );
  }
}

class AuthGateScreen extends StatelessWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _ImageViewerPage extends StatefulWidget {
  final String imageUrl;
  final String title;

  final Question? question;
  final int? questionId;
  final int? topicId;
  final String imageType;

  final int? index;
  final String? topicTitle;
  final int? packageId;
  final String? packageTitle;

  const _ImageViewerPage({
    required this.imageUrl,
    required this.title,
    this.question,
    this.questionId,
    this.topicId,
    required this.imageType,
    this.index,
    this.topicTitle,
    this.packageId,
    this.packageTitle,
  });

  @override
  State<_ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<_ImageViewerPage> {
  Question? _question;
  String _imageUrl = '';
  bool _loadRequested = false;

  @override
  void initState() {
    super.initState();

    _question = widget.question;
    _imageUrl = widget.imageUrl;

    if (_question != null && _imageUrl.isEmpty) {
      _imageUrl = _resolveImage(_question!);
    }
  }

  String _resolveImage(Question question) {
    if (widget.imageType == 'question') {
      return question.fullPageImage ?? '';
    }

    if (widget.imageType == 'answer') {
      return question.detailedAnswer?.fullPageImage ?? '';
    }

    return '';
  }

  void _goBackToQuestionDetail(BuildContext context) {
    if (widget.questionId == null ||
        widget.topicId == null ||
        widget.topicId! <= 0) {
      context.go('/home');
      return;
    }

    final uri = Uri(
      path: '/question-detail',
      queryParameters: {
        'questionId': '${widget.questionId}',
        'topicId': '${widget.topicId}',
      },
    ).toString();

    context.go(
      uri,
      extra: {
        'question': _question,
        'index': widget.index,
        'topicId': widget.topicId,
        'topicTitle': widget.topicTitle,
        'packageId': widget.packageId,
        'packageTitle': widget.packageTitle,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_question == null &&
        _imageUrl.isEmpty &&
        !_loadRequested &&
        widget.questionId != null &&
        widget.topicId != null &&
        widget.topicId! > 0) {
      _loadRequested = true;

      return BlocProvider(
        create: (_) => getIt<QuestionBloc>()
          ..add(
            GetQuestionByIdEvent(
              topicId: widget.topicId!,
              questionId: widget.questionId!,
            ),
          ),
        child: BlocConsumer<QuestionBloc, QuestionState>(
          listener: (context, state) {
            if (state is QuestionDetailLoaded) {
              setState(() {
                _question = state.question;
                _imageUrl = _resolveImage(state.question);
              });
            }
          },
          builder: (context, state) {
            if (state is QuestionDetailLoading || state is QuestionInitial) {
              return _buildLoadingScaffold();
            }

            if (state is QuestionDetailError) {
              return _buildErrorScaffold(state.message);
            }

            return _buildScaffold(context);
          },
        ),
      );
    }

    return _buildScaffold(context);
  }

  Widget _buildLoadingScaffold() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _goBackToQuestionDetail(context);
          },
        ),
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      ),
      body: const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  Widget _buildErrorScaffold(String message) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _goBackToQuestionDetail(context);
          },
        ),
        title: const Text('خطا', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _goBackToQuestionDetail(context);
          },
        ),
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          scaleEnabled: true,
          minScale: 0.5,
          maxScale: 5.0,
          child: _buildImage(context, _imageUrl),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, String path) {
    if (path.isEmpty) {
      return const Icon(Icons.broken_image, color: Colors.white, size: 60);
    }

    final resolved = path.startsWith('assets/')
        ? path
        : UrlHelper.resolve(path);

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

          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        },
        errorBuilder: (context, error, stack) =>
            const Icon(Icons.broken_image, color: Colors.white, size: 60),
      );
    }

    if (isSvg) {
      return SvgPicture.asset(
        path,
        height: MediaQuery.of(context).size.height * 0.75,
      );
    }

    return Image.asset(path, fit: BoxFit.contain);
  }
}
