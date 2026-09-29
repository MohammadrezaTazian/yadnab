import 'package:education_app/features/quiz/domain/entities/question.dart';
import 'package:education_app/features/quiz/domain/entities/detailed_answer.dart';
import 'package:education_app/shared/widgets/latex_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:education_app/injection_container.dart';
import 'package:education_app/features/comment/domain/usecases/toggle_like.dart';
import 'package:education_app/features/comment/presentation/widgets/comment_section_widget.dart';
import 'package:education_app/shared/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:education_app/shared/widgets/dio_network_svg_image.dart';
import 'package:education_app/core/utils/url_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:education_app/features/quiz/presentation/bloc/question_bloc.dart';
import 'package:education_app/features/quiz/presentation/bloc/question_event.dart';
import 'package:education_app/features/quiz/presentation/bloc/question_state.dart';

class QuestionDetailPage extends StatefulWidget {
  final Question? question;
  final int questionId;
  final int index;
  final int? topicId;
  final String? topicTitle;
  final int? packageId;
  final String? packageTitle;

  const QuestionDetailPage({
    super.key,
    this.question,
    required this.questionId,
    required this.index,
    this.topicId,
    this.topicTitle,
    this.packageId,
    this.packageTitle,
  });

  @override
  State<QuestionDetailPage> createState() => _QuestionDetailPageState();
}

class _QuestionDetailPageState extends State<QuestionDetailPage> {
  Question? _question;
  bool _loadRequested = false;
  bool _isAnswerVisible = false;
  bool _showComments = false;
  bool _isLiked = false;
  bool _showAnswerComments = false;
  bool _isAnswerLiked = false;
  int? _selectedOption;

  // View modes: 0 = Text Mode, 1 = Full Image Mode
  int _questionViewMode = 0;
  int _answerViewMode = 0;

  final TransformationController _questionTransformController =
      TransformationController();
  final TransformationController _answerTransformController =
      TransformationController();

  @override
  void initState() {
    super.initState();

    _question = widget.question;

    if (_question != null) {
      _isLiked = _question!.isLiked;

      if (_question!.detailedAnswer != null) {
        _isAnswerLiked = _question!.detailedAnswer!.isLiked;
      }
    }
  }

  Question get _currentQuestion => _question!;

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
    final result = await toggleLike(
      ToggleLikeParams(targetId: _currentQuestion.id, targetType: 1),
    );
    result.fold((failure) {}, (isLiked) {
      setState(() {
        _isLiked = isLiked;
      });
    });
  }

  Future<void> _toggleAnswerLike() async {
    if (_currentQuestion.detailedAnswer == null) return;

    final toggleLike = getIt<ToggleLike>();
    final result = await toggleLike(
      ToggleLikeParams(
        targetId: _currentQuestion.detailedAnswer!.id,
        targetType: 2,
      ),
    );
    result.fold((failure) {}, (isLiked) {
      setState(() {
        _isAnswerLiked = isLiked;
      });
    });
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

    if (optionIndex == _currentQuestion.correctOption) {
      return AppColors.quizCorrectBackground;
    }

    if (_selectedOption == optionIndex &&
        _selectedOption != _currentQuestion.correctOption) {
      return AppColors.quizWrongBackground;
    }

    return colorScheme.surface;
  }

  IconData? _getOptionIcon(int optionIndex) {
    if (!_isAnswerVisible) return null;

    if (optionIndex == _currentQuestion.correctOption) {
      return Icons.check_circle_rounded;
    }

    if (_selectedOption == optionIndex &&
        _selectedOption != _currentQuestion.correctOption) {
      return Icons.cancel_rounded;
    }

    return null;
  }

  Color? _getOptionIconColor(int optionIndex) {
    if (!_isAnswerVisible) return null;

    if (optionIndex == _currentQuestion.correctOption) {
      return AppColors.success;
    }

    if (_selectedOption == optionIndex &&
        _selectedOption != _currentQuestion.correctOption) {
      return AppColors.error;
    }

    return null;
  }

  void _showFullScreenImage(
    String imageUrl,
    String title, {
    required String imageType,
  }) {
    final uri = Uri(
      path: '/image-viewer',
      queryParameters: {
        'questionId': '${_currentQuestion.id}',
        'topicId': '${widget.topicId}',
        'imageType': imageType,
      },
    ).toString();

    context.go(
      uri,
      extra: {
        'imageUrl': imageUrl,
        'title': title,

        // ??????? ???? ???? ???? Back
        'question': _currentQuestion,
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
    if (_question == null) {
      return BlocProvider(
        create: (_) => getIt<QuestionBloc>(),
        child: BlocConsumer<QuestionBloc, QuestionState>(
          listener: (context, state) {
            if (state is QuestionDetailLoaded) {
              setState(() {
                _question = state.question;
                _isLiked = state.question.isLiked;

                if (state.question.detailedAnswer != null) {
                  _isAnswerLiked = state.question.detailedAnswer!.isLiked;
                }
              });
            }
          },
          builder: (context, state) {
            if (!_loadRequested) {
              _loadRequested = true;

              if (widget.topicId != null && widget.topicId! > 0) {
                context.read<QuestionBloc>().add(
                  GetQuestionByIdEvent(
                    topicId: widget.topicId!,
                    questionId: widget.questionId,
                  ),
                );
              }
            }

            if (state is QuestionDetailLoading ||
                state is QuestionInitial) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (state is QuestionDetailError) {
              return Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      context.go('/quiz-list?topicId=${widget.topicId}');
                    },
                  ),
                  title: const Text('???'),
                ),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }

            if (_question == null) {
              return const Scaffold(
                body: Center(
                  child: Text('??????? ???? ?? ????? ????.'),
                ),
              );
            }

            return _buildQuestionScaffold(context);
          },
        ),
      );
    }

    return _buildQuestionScaffold(context);
  }

  Widget _buildQuestionScaffold(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasFullImage = _currentQuestion.fullPageImage != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final uri = Uri(
              path: '/quiz-list',
              queryParameters: {
                if (widget.topicId != null) 'topicId': '${widget.topicId}',
                if (widget.topicTitle != null) 'topicTitle': widget.topicTitle!,
                if (widget.packageId != null)
                  'packageId': '${widget.packageId}',
                if (widget.packageTitle != null)
                  'packageTitle': widget.packageTitle!,
              },
            ).toString();

            context.go(uri);
          },
        ),
        title: Text('???? ${widget.index}'),
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
                        if (_currentQuestion.difficultyLevelName != null)
                          Chip(
                            label: Text(_currentQuestion.difficultyLevelName!),
                            backgroundColor: colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            labelStyle: textTheme.labelMedium?.copyWith(
                              color: colorScheme.primary,
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        if (_currentQuestion.questionYear != 0)
                          Text(
                            '???: ${_currentQuestion.questionYear}',
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
                            label: Text('????? ????'),
                            icon: Icon(Icons.text_fields_rounded, size: 18),
                          ),
                          ButtonSegment<int>(
                            value: 1,
                            label: const Text('????? ????'),
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
                            _questionTransformController.value =
                                Matrix4.identity();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Question Content based on selected View Mode
                    if (_questionViewMode == 0) ...[
                      // --- TEXT MODE ---
                      LatexText(
                        _currentQuestion.questionText,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Embedded Content Images (excluding full page)
                      if (_currentQuestion.contentImages.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 180,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _currentQuestion.contentImages.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final image =
                                  _currentQuestion.contentImages[index];
                              return _buildImage(
                                image.imageUrl,
                                180,
                                colorScheme,
                              );
                            },
                          ),
                        ),
                      ],
                    ] else ...[
                      // --- FULL IMAGE MODE ---
                      if (hasFullImage) ...[
                        _buildZoomableImageCard(
                          imageUrl: _currentQuestion.fullPageImage!,
                          imageType: 'question',
                          title: '????? ???? ???? ${widget.index}',
                          controller: _questionTransformController,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.image_not_supported_outlined,
                                size: 48,
                                color: colorScheme.outline,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '????? ???? ???? ??? ???? ??? ???? ???.',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.outline,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _questionViewMode = 0;
                                  });
                                },
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  size: 16,
                                ),
                                label: const Text('?????? ?? ????? ????'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],

                    const SizedBox(height: 24),

                    // Options (Conditional: Full text in Text mode, Compact Row in Image mode)
                    if (_questionViewMode == 0) ...[
                      _buildOption(
                        1,
                        _currentQuestion.option1,
                        colorScheme,
                        textTheme,
                      ),
                      _buildOption(
                        2,
                        _currentQuestion.option2,
                        colorScheme,
                        textTheme,
                      ),
                      _buildOption(
                        3,
                        _currentQuestion.option3,
                        colorScheme,
                        textTheme,
                      ),
                      _buildOption(
                        4,
                        _currentQuestion.option4,
                        colorScheme,
                        textTheme,
                      ),
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
                          _isAnswerVisible
                              ? '???? ???? ???? ??????'
                              : '????? ???? ??????',
                        ),
                      ),
                    ),

                    // Detailed Answer Section
                    if (_isAnswerVisible &&
                        _currentQuestion.detailedAnswer != null) ...[
                      const SizedBox(height: 24),
                      _buildDetailedAnswerSection(
                        _currentQuestion.detailedAnswer!,
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
                        _isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
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
                      color: _showComments
                          ? colorScheme.primary
                          : colorScheme.outline,
                      onPressed: _toggleComments,
                    ),
                  ],
                ),
              ),
            ),

            // Question Comments
            if (_showComments) ...[
              const SizedBox(height: 16),
              CommentSectionWidget(targetId: _currentQuestion.id, targetType: 1),
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
                '???? ??????:',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              if (hasAnswerFullImage)
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment<int>(value: 0, label: Text('???')),
                    ButtonSegment<int>(value: 1, label: Text('?????')),
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
            LatexText(answer.answerText, style: textTheme.bodyMedium),

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
              imageType: 'answer',
              title: '????? ???? ?????? ???? ${widget.index}',
              controller: _answerTransformController,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
          ],

          // Author
          if (answer.answerAuthor != null) ...[
            const SizedBox(height: 8),
            Text('???????: ${answer.answerAuthor}', style: textTheme.bodySmall),
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
            CommentSectionWidget(targetId: answer.id, targetType: 2),
          ],
        ],
      ),
    );
  }

  Widget _buildZoomableImageCard({
    required String imageUrl,
    required String title,
    required String imageType,
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
                Icon(
                  Icons.pinch_outlined,
                  size: 16,
                  color: colorScheme.outline,
                ),
                const SizedBox(width: 6),
                Text(
                  '?????? ??? ? ????????? ?????',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: '???????? ???',
                  icon: const Icon(Icons.restart_alt_rounded, size: 18),
                  onPressed: () {
                    controller.value = Matrix4.identity();
                  },
                ),
                IconButton(
                  tooltip: '???? ????',
                  icon: const Icon(Icons.fullscreen_rounded, size: 20),
                  onPressed: () => _showFullScreenImage(imageUrl, title, imageType: imageType),
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

  Widget _buildNetworkOrAssetImage(
    String imagePath,
    double height,
    BoxFit fit,
  ) {
    final resolvedPath = imagePath.startsWith('assets/')
        ? imagePath
        : UrlHelper.resolve(imagePath);
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
            child: Icon(
              Icons.broken_image_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
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
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? AppColors.onPrimary
                        : colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: LatexText(text, style: textTheme.bodyLarge)),
            if (_getOptionIcon(index) != null)
              Icon(_getOptionIcon(index), color: _getOptionIconColor(index)),
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
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '?????? ????? ????:',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (_selectedOption != null && !_isAnswerVisible)
                Text(
                  '????? $_selectedOption ?????? ???',
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
    final isCorrect =
        _isAnswerVisible && index == _currentQuestion.correctOption;
    final isWrong =
        _isAnswerVisible &&
        isSelected &&
        index != _currentQuestion.correctOption;

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
    final numberText = index >= 1 && index <= 4
        ? persianNumbers[index]
        : '$index';

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
                  ),
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
              '?????',
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











