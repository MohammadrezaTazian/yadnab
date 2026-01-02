import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/education_content_bloc.dart';
import '../bloc/education_content_event.dart';
import '../bloc/education_content_state.dart';
import 'education_content_detail_page.dart';

class EducationContentListPage extends StatelessWidget {
  final int topicItemId;
  final String topicTitle;

  const EducationContentListPage({
    super.key,
    required this.topicItemId,
    required this.topicTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<EducationContentBloc>()..add(GetEducationContentsByTopicEvent(topicItemId)),
      child: _EducationContentListView(topicItemId: topicItemId, topicTitle: topicTitle),
    );
  }
}

class _EducationContentListView extends StatelessWidget {
  final int topicItemId;
  final String topicTitle;

  const _EducationContentListView({required this.topicItemId, required this.topicTitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(topicTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      body: BlocBuilder<EducationContentBloc, EducationContentState>(
        builder: (context, state) {
          if (state is EducationContentLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EducationContentError) {
            return Center(child: Text(state.message));
          } else if (state is EducationContentLoaded) {
            if (state.contents.isEmpty) {
              return const Center(child: Text('آموزشی برای این مورد یافت نشد'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.contents.length,
              itemBuilder: (context, index) {
                final content = state.contents[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(
                      content.mediaType == 'Video' ? Icons.play_circle_fill : Icons.article,
                      color: Colors.blue,
                    ),
                    title: Text(content.title),
                    subtitle: Text(content.teacherName ?? 'نامشخص'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      final bloc = context.read<EducationContentBloc>();
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: bloc,
                            child: EducationContentDetailPage(content: content),
                          ),
                        ),
                      );
                      // Refetch education contents to get updated isLiked status
                      if (context.mounted) {
                        bloc.add(GetEducationContentsByTopicEvent(topicItemId));
                      }
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
