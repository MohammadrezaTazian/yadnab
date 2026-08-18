import 'package:education_app/features/quiz/domain/entities/question.dart';
import 'package:education_app/features/quiz/domain/entities/detailed_answer.dart';
import 'package:education_app/shared/widgets/latex_text.dart';
import 'package:flutter/material.dart';
import 'package:education_app/injection_container.dart';
import 'package:education_app/features/comment/domain/usecases/toggle_like.dart';
import 'package:education_app/features/comment/presentation/widgets/comment_section_widget.dart';
import 'package:education_app/shared/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:education_app/shared/widgets/dio_network_svg_image.dart';
import 'package:education_app/core/utils/url_helper.dart';

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

  // View modes: 0 = Text Mode, 1 = Full Image Mode
  int _questionViewMode = 0;
  int _answerViewMode = 0;

  final TransformationController _questionTransformController = TransformationController();
  final TransformationController _answerTransformController = TransformationController();

  @override
  void initState() {
    super.initState();
    _isLiked = widget.question.isLiked;
    if (widget.question.detailedAnswer != null) {
      _isAnswerLiked = widget.question.detailedAnswer!.isLiked;
    }
  }

  @override
  void dispose() {
    _questionTransformController.dispose();
    _answerTransformController.dispose();
    super.dispose();
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

  void _showFullScreenImage(String imageUrl, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
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
              child: _buildNetworkOrAssetImage(imageUrl, double.infinity, BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasFullImage = widget.question.fullPageImage != null;

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
                    // Question Metadata and Mode Switcher
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
                          )
                        else
                          const SizedBox.shrink(),
                        if (widget.question.questionYear != 0)
                          Text(
                            'سال: ${widget.question.questionYear}',
                            style: textTheme.bodySmall,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // View Mode Tabs (Segmented Button)
                    Center(
                      child: SegmentedButton<int>(
                        segments: [
                          const ButtonSegment<int>(
                            value: 0,
                            label: Text('نمایش متنی'),
                            icon: Icon(Icons.text_fields_rounded, size: 18),
                          ),
                          ButtonSegment<int>(
                            value: 1,
                            label: const Text('تصویر کامل'),
                            icon: Icon(
                              Icons.image_outlined,
                              size: 18,
                              color: hasFullImage ? null : colorScheme.outline,
                            ),
                          ),
                        ],
                        selected: {_questionViewMode},
                        onSelectionChanged: (Set<int> newSelection) {
                          setState(() {
                            _questionViewMode = newSelection.first;
                            _questionTransformController.value = Matrix4.identity();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Question Content based on selected View Mode
                    if (_questionViewMode == 0) ...[
                      // --- TEXT MODE ---
                      LatexText(
                        widget.question.questionText,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Embedded Content Images (excluding full page)
                      if (widget.question.contentImages.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 180,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.question.contentImages.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final image = widget.question.contentImages[index];
                              return _buildImage(image.imageUrl, 180, colorScheme);
                            },
                          ),
                        ),
                      ],
                    ] else ...[
                      // --- FULL IMAGE MODE ---
                      if (hasFullImage) ...[
                        _buildZoomableImageCard(
                          imageUrl: widget.question.fullPageImage!,
                          title: 'تصویر کامل سوال ${widget.index}',
                          controller: _questionTransformController,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colorScheme.outlineVariant),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.image_not_supported_outlined, size: 48, color: colorScheme.outline),
                              const SizedBox(height: 12),
                              Text(
                                'تصویر کامل برای این سوال ثبت نشده است.',
                                style: textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _questionViewMode = 0;
                                  });
                                },
                                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                                label: const Text('بازگشت به نمایش متنی'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],

                    const SizedBox(height: 24),

                    // Options (Conditional: Full text in Text mode, Compact Row in Image mode)
                    if (_questionViewMode == 0) ...[
                      _buildOption(1, widget.question.option1, colorScheme, textTheme),
                      _buildOption(2, widget.question.option2, colorScheme, textTheme),
                      _buildOption(3, widget.question.option3, colorScheme, textTheme),
                      _buildOption(4, widget.question.option4, colorScheme, textTheme),
                    ] else ...[
                      _buildCompactOptionsRow(colorScheme, textTheme),
                    ],

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
                      _buildDetailedAnswerSection(
                        widget.question.detailedAnswer!,
                        colorScheme,
                        textTheme,
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

  Widget _buildDetailedAnswerSection(
    DetailedAnswer answer,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final hasAnswerFullImage = answer.fullPageImage != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.quizCorrectBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'پاسخ تشریحی:',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              if (hasAnswerFullImage)
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment<int>(value: 0, label: Text('متن')),
                    ButtonSegment<int>(value: 1, label: Text('تصویر')),
                  ],
                  selected: {_answerViewMode},
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onSelectionChanged: (Set<int> newSelection) {
                    setState(() {
                      _answerViewMode = newSelection.first;
                      _answerTransformController.value = Matrix4.identity();
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (_answerViewMode == 0 || !hasAnswerFullImage) ...[
            LatexText(
              answer.answerText,
              style: textTheme.bodyMedium,
            ),

            // Answer Images
            if (answer.contentImages.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: answer.contentImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final image = answer.contentImages[index];
                    return _buildImage(image.imageUrl, 150, colorScheme);
                  },
                ),
              ),
            ],
          ] else ...[
            _buildZoomableImageCard(
              imageUrl: answer.fullPageImage!,
              title: 'تصویر پاسخ تشریحی سوال ${widget.index}',
              controller: _answerTransformController,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
          ],

          // Author
          if (answer.answerAuthor != null) ...[
            const SizedBox(height: 8),
            Text(
              'نویسنده: ${answer.answerAuthor}',
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
              targetId: answer.id,
              targetType: 2,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildZoomableImageCard({
    required String imageUrl,
    required String title,
    required TransformationController controller,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Toolbar for zoom / fullscreen
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            child: Row(
              children: [
                Icon(Icons.pinch_outlined, size: 16, color: colorScheme.outline),
                const SizedBox(width: 6),
                Text(
                  'قابلیت زوم و جابه‌جایی تصویر',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'بازنشانی زوم',
                  icon: const Icon(Icons.restart_alt_rounded, size: 18),
                  onPressed: () {
                    controller.value = Matrix4.identity();
                  },
                ),
                IconButton(
                  tooltip: 'تمام صفحه',
                  icon: const Icon(Icons.fullscreen_rounded, size: 20),
                  onPressed: () => _showFullScreenImage(imageUrl, title),
                ),
              ],
            ),
          ),

          // InteractiveViewer
          SizedBox(
            height: 320,
            width: double.infinity,
            child: InteractiveViewer(
              transformationController: controller,
              minScale: 1.0,
              maxScale: 4.5,
              panEnabled: true,
              scaleEnabled: true,
              child: Center(
                child: _buildNetworkOrAssetImage(imageUrl, 320, BoxFit.contain),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkOrAssetImage(String imagePath, double height, BoxFit fit) {
    final resolvedPath = imagePath.startsWith('assets/') ? imagePath : UrlHelper.resolve(imagePath);
    final isSvg = resolvedPath.toLowerCase().endsWith('.svg');
    final isNetwork = resolvedPath.toLowerCase().startsWith('http');

    if (isNetwork) {
      if (isSvg) {
        return DioNetworkSvgImage(imageUrl: resolvedPath, height: height);
      } else {
        return Image.network(
          resolvedPath,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(Icons.broken_image_rounded, size: 48, color: Theme.of(context).colorScheme.outline),
          ),
        );
      }
    } else {
      if (isSvg) {
        return SvgPicture.asset(imagePath, height: height);
      } else {
        return Image.asset(imagePath, fit: fit);
      }
    }
  }

  Widget _buildImage(String imagePath, double height, ColorScheme colorScheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: _buildNetworkOrAssetImage(imagePath, height, BoxFit.cover),
    );
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

  Widget _buildCompactOptionsRow(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'انتخاب گزینه پاسخ:',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (_selectedOption != null && !_isAnswerVisible)
                Text(
                  'گزینه $_selectedOption انتخاب شده',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCompactOptionButton(1, colorScheme, textTheme),
              _buildCompactOptionButton(2, colorScheme, textTheme),
              _buildCompactOptionButton(3, colorScheme, textTheme),
              _buildCompactOptionButton(4, colorScheme, textTheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactOptionButton(
    int index,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final isSelected = _selectedOption == index;
    final isCorrect = _isAnswerVisible && index == widget.question.correctOption;
    final isWrong = _isAnswerVisible && isSelected && index != widget.question.correctOption;

    Color bgColor = colorScheme.surface;
    Color borderColor = colorScheme.outlineVariant;
    Color textColor = colorScheme.onSurface;
    IconData? icon;
    Color? iconColor;

    if (_isAnswerVisible) {
      if (isCorrect) {
        bgColor = AppColors.quizCorrectBackground;
        borderColor = AppColors.success;
        textColor = AppColors.success;
        icon = Icons.check_circle_rounded;
        iconColor = AppColors.success;
      } else if (isWrong) {
        bgColor = AppColors.quizWrongBackground;
        borderColor = AppColors.error;
        textColor = AppColors.error;
        icon = Icons.cancel_rounded;
        iconColor = AppColors.error;
      }
    } else if (isSelected) {
      bgColor = colorScheme.primary;
      borderColor = colorScheme.primary;
      textColor = AppColors.onPrimary;
    }

    final persianNumbers = ['۰', '۱', '۲', '۳', '۴'];
    final numberText = index >= 1 && index <= 4 ? persianNumbers[index] : '$index';

    return InkWell(
      onTap: () => _selectOption(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 68,
        height: 56,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isSelected || isCorrect || isWrong ? 2 : 1.2,
          ),
          boxShadow: isSelected && !_isAnswerVisible
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  numberText,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 4),
                  Icon(icon, size: 16, color: iconColor),
                ],
              ],
            ),
            Text(
              'گزینه',
              style: textTheme.labelSmall?.copyWith(
                color: isSelected && !_isAnswerVisible
                    ? AppColors.onPrimary.withValues(alpha: 0.8)
                    : colorScheme.outline,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
