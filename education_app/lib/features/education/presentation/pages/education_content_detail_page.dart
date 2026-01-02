import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/education_content.dart';
import '../bloc/education_content_bloc.dart';
import '../bloc/education_content_event.dart';
import '../bloc/education_content_state.dart';
import 'package:education_app/features/comment/presentation/widgets/comment_section_widget.dart';
import 'package:education_app/shared/widgets/dio_network_svg_image.dart';
import 'package:education_app/shared/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EducationContentDetailPage extends StatefulWidget {
  final EducationContent content;

  const EducationContentDetailPage({super.key, required this.content});

  @override
  State<EducationContentDetailPage> createState() => _EducationContentDetailPageState();
}

class _EducationContentDetailPageState extends State<EducationContentDetailPage> {
  bool _showComments = false;

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
        // Get the latest content from state if available
        EducationContent currentContent = widget.content;
        if (state is EducationContentLoaded) {
          final found = state.contents.where((c) => c.id == widget.content.id);
          if (found.isNotEmpty) {
            currentContent = found.first;
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(currentContent.title),
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
                        if (currentContent.mediaUrl != null && currentContent.mediaType == 'Image')
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              currentContent.mediaUrl!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox(height: 200, child: Center(child: Icon(Icons.broken_image))),
                            ),
                          ),

                        if (currentContent.mediaUrl != null && currentContent.mediaType == 'Video')
                          Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Icon(Icons.play_circle_outline_rounded, size: 64, color: colorScheme.primary),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Teacher Name
                        if (currentContent.teacherName != null)
                          Row(
                            children: [
                              Icon(Icons.person_rounded, size: 20, color: colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                'مدرس: ${currentContent.teacherName}',
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
                              final isSvg = imagePath.toLowerCase().endsWith('.svg');
                              final isNetwork = imagePath.toLowerCase().startsWith('http');

                              if (isNetwork) {
                                if (isSvg) {
                                  return DioNetworkSvgImage(
                                    imageUrl: imagePath,
                                    height: 180,
                                  );
                                } else {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imagePath,
                                      height: 180,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const SizedBox(
                                          height: 180,
                                          width: 180,
                                          child: Center(child: CircularProgressIndicator()),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) => SizedBox(
                                        height: 180,
                                        width: 180,
                                        child: Center(
                                          child: Icon(Icons.broken_image_rounded, size: 50, color: colorScheme.outline),
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
                        Text(
                          currentContent.contentText,
                          style: textTheme.bodyLarge?.copyWith(
                            height: 1.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Actions
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Like Button - Using BLoC
                        IconButton(
                          icon: Icon(
                            currentContent.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          ),
                          color: currentContent.isLiked ? AppColors.error : colorScheme.outline,
                          onPressed: () {
                            context.read<EducationContentBloc>().add(ToggleLikeEvent(currentContent.id));
                          },
                        ),
                        // Comment Button
                        IconButton(
                          icon: Icon(
                            _showComments ? Icons.chat_bubble_rounded : Icons.chat_bubble_outline_rounded,
                          ),
                          color: _showComments ? colorScheme.primary : colorScheme.outline,
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
        );
      },
    );
  }
}



