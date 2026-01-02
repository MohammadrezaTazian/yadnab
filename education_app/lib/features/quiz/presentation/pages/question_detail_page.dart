import 'package:education_app/features/quiz/domain/entities/question.dart';
import 'package:education_app/shared/widgets/latex_text.dart';
import 'package:flutter/material.dart';
import 'package:education_app/injection_container.dart';
import 'package:education_app/features/comment/domain/usecases/toggle_like.dart';
import 'package:education_app/features/comment/presentation/widgets/comment_section_widget.dart';
import 'package:education_app/shared/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:education_app/shared/widgets/dio_network_svg_image.dart';

class QuestionDetailPage extends StatefulWidget {
  final Question question;
  final int index;

  const QuestionDetailPage({
    super.key,
    required this.question,
    required this.index,
  });

  @override
  State<QuestionDetailPage> createState() => _QuestionDetailPageState();
}

class _QuestionDetailPageState extends State<QuestionDetailPage> {
  bool _isAnswerVisible = false;
  bool _showComments = false;
  bool _isLiked = false;
  bool _showAnswerComments = false;
  bool _isAnswerLiked = false;
  int? _selectedOption;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.question.isLiked;
    if (widget.question.detailedAnswer != null) {
      _isAnswerLiked = widget.question.detailedAnswer!.isLiked;
    }
  }

  void _toggleAnswer() {
    setState(() {
      _isAnswerVisible = !_isAnswerVisible;
    });
  }

  void _toggleComments() {
    setState(() {
      _showComments = !_showComments;
    });
  }

  void _toggleAnswerComments() {
    setState(() {
      _showAnswerComments = !_showAnswerComments;
    });
  }

  Future<void> _toggleLike() async {
    final toggleLike = getIt<ToggleLike>();
    final result = await toggleLike(ToggleLikeParams(
      targetId: widget.question.id,
      targetType: 1,
    ));
    result.fold(
      (failure) {},
      (isLiked) {
        setState(() {
          _isLiked = isLiked;
        });
      },
    );
  }

  Future<void> _toggleAnswerLike() async {
    if (widget.question.detailedAnswer == null) return;

    final toggleLike = getIt<ToggleLike>();
    final result = await toggleLike(ToggleLikeParams(
      targetId: widget.question.detailedAnswer!.id,
      targetType: 2,
    ));
    result.fold(
      (failure) {},
      (isLiked) {
        setState(() {
          _isAnswerLiked = isLiked;
        });
      },
    );
  }

  void _selectOption(int optionIndex) {
    if (_isAnswerVisible) return;
    setState(() {
      _selectedOption = optionIndex;
    });
  }

  Color _getOptionColor(int optionIndex, ColorScheme colorScheme) {
    if (!_isAnswerVisible) {
      return _selectedOption == optionIndex
          ? AppColors.quizSelectedOption
          : colorScheme.surface;
    }

    if (optionIndex == widget.question.correctOption) {
      return AppColors.quizCorrectBackground;
    }

    if (_selectedOption == optionIndex &&
        _selectedOption != widget.question.correctOption) {
      return AppColors.quizWrongBackground;
    }

    return colorScheme.surface;
  }

  IconData? _getOptionIcon(int optionIndex) {
    if (!_isAnswerVisible) return null;

    if (optionIndex == widget.question.correctOption) {
      return Icons.check_circle_rounded;
    }

    if (_selectedOption == optionIndex &&
        _selectedOption != widget.question.correctOption) {
      return Icons.cancel_rounded;
    }

    return null;
  }

  Color? _getOptionIconColor(int optionIndex) {
    if (!_isAnswerVisible) return null;

    if (optionIndex == widget.question.correctOption) {
      return AppColors.success;
    }

    if (_selectedOption == optionIndex &&
        _selectedOption != widget.question.correctOption) {
      return AppColors.error;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('سوال ${widget.index}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Main Question Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Metadata
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.question.difficultyLevelName != null)
                          Chip(
                            label: Text(widget.question.difficultyLevelName!),
                            backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                            labelStyle: textTheme.labelMedium?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        if (widget.question.questionYear != 0)
                          Text(
                            'سال: ${widget.question.questionYear}',
                            style: textTheme.bodySmall,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Question Text
                    LatexText(
                      widget.question.questionText,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Question Images
                    if (widget.question.questionImages.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 180,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.question.questionImages.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final image = widget.question.questionImages[index];
                            return _buildImage(image.imageUrl, 180, colorScheme);
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Options
                    _buildOption(1, widget.question.option1, colorScheme, textTheme),
                    _buildOption(2, widget.question.option2, colorScheme, textTheme),
                    _buildOption(3, widget.question.option3, colorScheme, textTheme),
                    _buildOption(4, widget.question.option4, colorScheme, textTheme),

                    const SizedBox(height: 24),

                    // Toggle Answer Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _toggleAnswer,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: _isAnswerVisible
                              ? colorScheme.outline
                              : colorScheme.primary,
                        ),
                        child: Text(
                          _isAnswerVisible ? 'مخفی کردن پاسخ تشریحی' : 'نمایش پاسخ تشریحی',
                        ),
                      ),
                    ),

                    // Detailed Answer Section
                    if (_isAnswerVisible && widget.question.detailedAnswer != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.quizCorrectBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'پاسخ تشریحی:',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(height: 8),
                            LatexText(
                              widget.question.detailedAnswer!.answerText,
                              style: textTheme.bodyMedium,
                            ),

                            // Answer Images
                            if (widget.question.detailedAnswer!.answerImages.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 150,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: widget.question.detailedAnswer!.answerImages.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                                  itemBuilder: (context, index) {
                                    final image = widget.question.detailedAnswer!.answerImages[index];
                                    return _buildImage(image.imageUrl, 150, colorScheme);
                                  },
                                ),
                              ),
                            ],

                            // Author
                            if (widget.question.detailedAnswer!.answerAuthor != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'نویسنده: ${widget.question.detailedAnswer!.answerAuthor}',
                                style: textTheme.bodySmall,
                              ),
                            ],

                            const SizedBox(height: 16),
                            Divider(color: AppColors.success.withValues(alpha: 0.3)),

                            // Answer Actions
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _isAnswerLiked
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                  ),
                                  color: _isAnswerLiked ? AppColors.error : colorScheme.outline,
                                  onPressed: _toggleAnswerLike,
                                ),
                                IconButton(
                                  icon: Icon(
                                    _showAnswerComments
                                        ? Icons.chat_bubble_rounded
                                        : Icons.chat_bubble_outline_rounded,
                                  ),
                                  color: _showAnswerComments
                                      ? colorScheme.primary
                                      : colorScheme.outline,
                                  onPressed: _toggleAnswerComments,
                                ),
                              ],
                            ),

                            // Answer Comments
                            if (_showAnswerComments) ...[
                              const SizedBox(height: 8),
                              CommentSectionWidget(
                                targetId: widget.question.detailedAnswer!.id,
                                targetType: 2,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Question Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      ),
                      color: _isLiked ? AppColors.error : colorScheme.outline,
                      onPressed: _toggleLike,
                    ),
                    IconButton(
                      icon: Icon(
                        _showComments
                            ? Icons.chat_bubble_rounded
                            : Icons.chat_bubble_outline_rounded,
                      ),
                      color: _showComments ? colorScheme.primary : colorScheme.outline,
                      onPressed: _toggleComments,
                    ),
                  ],
                ),
              ),
            ),

            // Question Comments
            if (_showComments) ...[
              const SizedBox(height: 16),
              CommentSectionWidget(
                targetId: widget.question.id,
                targetType: 1,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imagePath, double height, ColorScheme colorScheme) {
    final isSvg = imagePath.toLowerCase().endsWith('.svg');
    final isNetwork = imagePath.toLowerCase().startsWith('http');

    if (isNetwork) {
      if (isSvg) {
        return DioNetworkSvgImage(imageUrl: imagePath, height: height);
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imagePath,
            height: height,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SizedBox(
                height: height,
                width: height,
                child: const Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder: (context, error, stackTrace) => SizedBox(
              height: height,
              width: height,
              child: Center(
                child: Icon(Icons.broken_image_rounded, size: 40, color: colorScheme.outline),
              ),
            ),
          ),
        );
      }
    } else {
      if (isSvg) {
        return SvgPicture.asset(imagePath, height: height);
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(imagePath, height: height),
        );
      }
    }
  }

  Widget _buildOption(
    int index,
    String text,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final isSelected = _selectedOption == index;

    return GestureDetector(
      onTap: () => _selectOption(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getOptionColor(index, colorScheme),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: textTheme.labelLarge?.copyWith(
                    color: isSelected ? AppColors.onPrimary : colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LatexText(
                text,
                style: textTheme.bodyLarge,
              ),
            ),
            if (_getOptionIcon(index) != null)
              Icon(
                _getOptionIcon(index),
                color: _getOptionIconColor(index),
              ),
          ],
        ),
      ),
    );
  }
}



