import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/education_content.dart';
import '../bloc/education_content_bloc.dart';
import '../bloc/education_content_event.dart';
import '../bloc/education_content_state.dart';
import 'package:education_app/features/comment/presentation/widgets/comment_section_widget.dart';
import 'package:education_app/shared/widgets/dio_network_svg_image.dart';
import 'package:education_app/shared/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:education_app/core/utils/url_helper.dart';
import 'package:education_app/shared/widgets/latex_text.dart';
import '../widgets/education_content_viewer.dart';

class EducationContentDetailPage extends StatefulWidget {
  final EducationContent? content;
  final int? contentId;

  final int? topicId;
  final String? topicTitle;
  final int? packageId;
  final String? packageTitle;

  const EducationContentDetailPage({
    super.key,
    this.content,
    this.contentId,
    this.topicId,
    this.topicTitle,
    this.packageId,
    this.packageTitle,
  });

  @override
  State<EducationContentDetailPage> createState() =>
      _EducationContentDetailPageState();
}

class _EducationContentDetailPageState
    extends State<EducationContentDetailPage> {
  bool _showComments = false;

  void _goBackToEducationContent() {
    final uri = Uri(
      path: '/education-content',
      queryParameters: {
        if (widget.topicId != null) 'topicId': '${widget.topicId}',
        if (widget.topicTitle != null) 'topicTitle': widget.topicTitle!,
        if (widget.packageId != null) 'packageId': '${widget.packageId}',
        if (widget.packageTitle != null) 'packageTitle': widget.packageTitle!,
      },
    );

    context.go(uri.toString());
  }

  @override
  void initState() {
    super.initState();

    if (widget.content == null && widget.contentId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        context.read<EducationContentBloc>().add(
          GetEducationContentByIdEvent(widget.contentId!),
        );
      });
    }
  }

  void _toggleComments() {
    setState(() {
      _showComments = !_showComments;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<EducationContentBloc, EducationContentState>(
      builder: (context, state) {
        EducationContent? currentContent = widget.content;

        if (state is EducationContentDetailLoaded) {
          currentContent = state.content;
        } else if (state is EducationContentLoaded && currentContent != null) {
          final found = state.contents.where((c) => c.id == currentContent!.id);
          if (found.isNotEmpty) {
            currentContent = found.first;
          }
        }

        if (currentContent == null) {
          return PopScope(
            canPop: defaultTargetPlatform != TargetPlatform.android,
            onPopInvokedWithResult: (didPop, result) {
              debugPrint(
                'EDUCATION CONTENT DETAIL BACK: didPop=$didPop, platform=$defaultTargetPlatform',
              );

              if (!didPop && defaultTargetPlatform == TargetPlatform.android) {
                _goBackToEducationContent();
              }
            },
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _goBackToEducationContent,
                ),
                title: const Text(
                  '\u0645\u062d\u062a\u0648\u0627\u06cc \u0622\u0645\u0648\u0632\u0634\u06cc',
                ),
              ),
              body: Center(
                child: state is EducationContentError
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(state.message, textAlign: TextAlign.center),
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          );
        }

        return PopScope(
          canPop: defaultTargetPlatform != TargetPlatform.android,
          onPopInvokedWithResult: (didPop, result) {
            debugPrint(
              'EDUCATION CONTENT DETAIL BACK: didPop=$didPop, platform=$defaultTargetPlatform',
            );

            if (!didPop && defaultTargetPlatform == TargetPlatform.android) {
              _goBackToEducationContent();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goBackToEducationContent,
              ),
              title: LatexText(
                currentContent.title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Main Content Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Media (Image/Video)
                          if (currentContent.mediaUrl != null &&
                              currentContent.mediaType == 'Image')
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                UrlHelper.resolve(currentContent.mediaUrl!),
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const SizedBox(
                                      height: 200,
                                      child: Center(
                                        child: Icon(Icons.broken_image),
                                      ),
                                    ),
                              ),
                            ),

                          if (currentContent.mediaUrl != null &&
                              currentContent.mediaType == 'Video')
                            Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.play_circle_outline_rounded,
                                  size: 64,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),

                          const SizedBox(height: 16),

                          // Teacher Name
                          if (currentContent.teacherName != null)
                            Row(
                              children: [
                                Icon(
                                  Icons.person_rounded,
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '\u0645\u062f\u0631\u0633: ${currentContent.teacherName}',
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                          const SizedBox(height: 16),

                          // Content Images
                          if (currentContent.images.isNotEmpty) ...[
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: currentContent.images.map((image) {
                                final imagePath = image.imageUrl;
                                final resolvedPath =
                                    imagePath.startsWith('assets/')
                                    ? imagePath
                                    : UrlHelper.resolve(imagePath);
                                final isSvg = resolvedPath
                                    .toLowerCase()
                                    .endsWith('.svg');
                                final isNetwork = resolvedPath
                                    .toLowerCase()
                                    .startsWith('http');

                                if (isNetwork) {
                                  if (isSvg) {
                                    return DioNetworkSvgImage(
                                      imageUrl: resolvedPath,
                                      height: 180,
                                    );
                                  } else {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        resolvedPath,
                                        height: 180,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return const SizedBox(
                                                height: 180,
                                                width: 180,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              );
                                            },
                                        errorBuilder:
                                            (
                                              context,
                                              error,
                                              stackTrace,
                                            ) => SizedBox(
                                              height: 180,
                                              width: 180,
                                              child: Center(
                                                child: Icon(
                                                  Icons.broken_image_rounded,
                                                  size: 50,
                                                  color: colorScheme.outline,
                                                ),
                                              ),
                                            ),
                                      ),
                                    );
                                  }
                                } else {
                                  if (isSvg) {
                                    return SvgPicture.asset(
                                      imagePath,
                                      height: 180,
                                    );
                                  } else {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        imagePath,
                                        height: 180,
                                      ),
                                    );
                                  }
                                }
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                          ],

                          const Divider(),
                          const SizedBox(height: 16),

                          // Content Text
                          EducationContentViewer(
                            content: currentContent.contentText,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Actions
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Like Button - Using BLoC
                          IconButton(
                            icon: Icon(
                              currentContent.isLiked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                            ),
                            color: currentContent.isLiked
                                ? AppColors.error
                                : colorScheme.outline,
                            onPressed: () {
                              context.read<EducationContentBloc>().add(
                                ToggleLikeEvent(currentContent!.id),
                              );
                            },
                          ),
                          // Comment Button
                          IconButton(
                            icon: Icon(
                              _showComments
                                  ? Icons.chat_bubble_rounded
                                  : Icons.chat_bubble_outline_rounded,
                            ),
                            color: _showComments
                                ? colorScheme.primary
                                : colorScheme.outline,
                            onPressed: _toggleComments,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Comments Section
                  if (_showComments) ...[
                    const SizedBox(height: 24),
                    CommentSectionWidget(
                      targetId: currentContent.id,
                      targetType: 3,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
