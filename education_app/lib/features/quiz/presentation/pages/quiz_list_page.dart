import 'package:education_app/shared/widgets/latex_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/bloc/question_bloc.dart';
import '../../presentation/bloc/question_event.dart';
import '../../presentation/bloc/question_state.dart';
import '../../../../injection_container.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/app_search.dart';
import 'question_detail_page.dart';

class QuizListPage extends StatelessWidget {
  final int topicId;
  final String topicTitle;

  const QuizListPage({
    super.key,
    required this.topicId,
    required this.topicTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<QuestionBloc>()..add(GetQuestionsEvent(topicId)),
      child: _QuizListPageContent(topicId: topicId, topicTitle: topicTitle),
    );
  }
}

class _QuizListPageContent extends StatefulWidget {
  final int topicId;
  final String topicTitle;

  const _QuizListPageContent({required this.topicId, required this.topicTitle});

  @override
  State<_QuizListPageContent> createState() => _QuizListPageContentState();
}

class _QuizListPageContentState extends State<_QuizListPageContent>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _searchBarAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchBarAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<QuestionBloc, QuestionState>(
      listenWhen: (previous, current) {
        if (previous is QuestionLoaded && current is QuestionLoaded) {
          return previous.isSearching != current.isSearching;
        }
        return current is QuestionLoaded && current.isSearching;
      },
      listener: (context, state) {
        if (state is QuestionLoaded) {
          if (state.isSearching) {
            _animationController.forward();
            Future.delayed(const Duration(milliseconds: 200), () {
              _searchFocusNode.requestFocus();
            });
          } else {
            _animationController.reverse();
            _searchController.clear();
            _searchFocusNode.unfocus();
          }
        }
      },
      builder: (context, state) {
        final isSearching = state is QuestionLoaded && state.isSearching;
        final searchQuery = state is QuestionLoaded ? state.searchQuery : '';

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.topicTitle),
            centerTitle: true,
            actions: [
              SearchAppBarAction(
                isSearching: isSearching,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                onPressed: () {
                  context.read<QuestionBloc>().add(ToggleQuestionsSearchVisibilityEvent());
                },
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: Column(
            children: [
              AppSearchBar(
                controller: _searchController,
                focusNode: _searchFocusNode,
                animation: _searchBarAnimation,
                hasQuery: searchQuery.isNotEmpty,
                hintText: 'جستجوی سوالات...',
                onChanged: (query) {
                  context.read<QuestionBloc>().add(SearchQuestionsEvent(query));
                },
                onClear: () {
                  context.read<QuestionBloc>().add(ClearQuestionsSearchEvent());
                },
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (state is QuestionLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is QuestionLoaded) {
                      final questions = state.filteredQuestions;

                      if (questions.isEmpty) {
                        if (searchQuery.isNotEmpty) {
                          return SearchEmptyState(
                            query: searchQuery,
                            subtitle: '«$searchQuery» در سوالات پیدا نشد',
                          );
                        }
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.quiz_outlined,
                                size: 64,
                                color: colorScheme.outline,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'سوال موجود نیست',
                                style: textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          final question = questions[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                child: Text('${index + 1}'),
                              ),
                              title: searchQuery.isNotEmpty
                                  ? HighlightedText(
                                      text: question.questionText,
                                      query: searchQuery,
                                      style: textTheme.bodyLarge,
                                    )
                                  : LatexText(
                                      question.questionText,
                                      style: textTheme.bodyLarge,
                                    ),
                              trailing: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: colorScheme.outline,
                              ),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QuestionDetailPage(
                                      question: question,
                                      index: index + 1,
                                    ),
                                  ),
                                );
                                if (context.mounted) {
                                  context.read<QuestionBloc>().add(GetQuestionsEvent(widget.topicId));
                                }
                              },
                            ),
                          );
                        },
                      );
                    } else if (state is QuestionError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 64,
                              color: colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              style: textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


