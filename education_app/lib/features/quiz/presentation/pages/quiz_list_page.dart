import 'package:education_app/shared/widgets/latex_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/bloc/question_bloc.dart';
import '../../presentation/bloc/question_event.dart';
import '../../presentation/bloc/question_state.dart';
import '../../../../injection_container.dart';
import 'question_detail_page.dart';

class QuizListPage extends StatefulWidget {
  final int topicItemId;
  final String topicTitle;

  const QuizListPage({
    super.key,
    required this.topicItemId,
    required this.topicTitle,
  });

  @override
  State<QuizListPage> createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider(
      create: (_) => sl<QuestionBloc>()..add(GetQuestionsEvent(widget.topicItemId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.topicTitle),
          centerTitle: true,
        ),
        body: BlocBuilder<QuestionBloc, QuestionState>(
          builder: (context, state) {
            if (state is QuestionLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is QuestionLoaded) {
              if (state.questions.isEmpty) {
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
                itemCount: state.questions.length,
                itemBuilder: (context, index) {
                  final question = state.questions[index];
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
                      title: LatexText(
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
                          context.read<QuestionBloc>().add(GetQuestionsEvent(widget.topicItemId));
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
    );
  }
}

