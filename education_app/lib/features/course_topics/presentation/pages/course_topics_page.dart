import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:education_app/features/course_topics/presentation/bloc/course_topic_bloc.dart';
import 'package:education_app/features/course_topics/presentation/bloc/course_topic_event.dart';
import 'package:education_app/features/course_topics/presentation/bloc/course_topic_state.dart';
import 'package:education_app/features/course_topics/data/models/topic_item_model.dart';
import 'package:education_app/injection_container.dart';
import 'package:education_app/features/quiz/presentation/pages/quiz_list_page.dart';
import 'package:education_app/features/education/presentation/pages/education_content_list_page.dart';

class CourseTopicsPage extends StatelessWidget {
  final String category;
  final String title;

  const CourseTopicsPage({
    super.key,
    required this.category,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CourseTopicBloc>()..add(LoadCourseTopics(category)),
      child: _CourseTopicsPageContent(title: title),
    );
  }
}

class _CourseTopicsPageContent extends StatelessWidget {
  final String title;

  const _CourseTopicsPageContent({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF0A0E27),
                    const Color(0xFF1A1F3A),
                    const Color(0xFF16213E),
                  ]
                : [
                    Colors.blue.shade50,
                    Colors.white,
                  ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 150.0,
              floating: false,
              pinned: true,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: isDark ? const Color(0xFFF5F5FA) : Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  title,
                  style: TextStyle(
                    color: isDark ? const Color(0xFFF5F5FA) : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              const Color(0xFF1A1F3A),
                              const Color(0xFF252B48),
                            ]
                          : [
                              Colors.blue.shade700,
                              Colors.blue.shade500,
                            ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.menu_book,
                      size: 60,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
            ),
            BlocBuilder<CourseTopicBloc, CourseTopicState>(
              builder: (context, state) {
                if (state is CourseTopicLoading) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (state is CourseTopicError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 60,
                              color: Colors.red.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'خطا در بارگذاری',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFFE8E8F0) : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark ? const Color(0xFFB8B8CC) : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                context.read<CourseTopicBloc>().add(LoadCourseTopics(category));
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('تلاش مجدد'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else if (state is CourseTopicLoaded) {
                  return SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final topicItem = state.courseTopic.topics[index];
                          return _buildTopicItem(
                            context,
                            topicItem,
                            index,
                            isDark,
                          );
                        },
                        childCount: state.courseTopic.topics.length,
                      ),
                    ),
                  );
                }
                return const SliverFillRemaining(
                  child: Center(
                    child: Text('No data'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicItem(BuildContext context, TopicItemModel topicItem, int index, bool isDark) {
    final hasChildren = topicItem.children.isNotEmpty;

    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
    ];
    final color = colors[index % colors.length];

    if (hasChildren) {
      // Parent Node -> ExpansionTile
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        color: isDark ? const Color(0xFF252B48) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isDark ? BorderSide(color: color.withValues(alpha: 0.3)) : BorderSide.none,
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.folder_open, color: color),
            ),
            title: Text(
              topicItem.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? const Color(0xFFE8E8F0) : Colors.black87,
              ),
            ),
            childrenPadding: const EdgeInsets.only(left: 16, bottom: 8),
            children: topicItem.children
                .asMap()
                .entries
                .map((entry) => _buildTopicItem(context, entry.value, entry.key, isDark))
                .toList(),
          ),
        ),
      );
    } else {
      // Leaf Node (Original Design)
      return TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 300 + (index * 100)),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 3,
          color: isDark ? const Color(0xFF252B48) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isDark
                ? BorderSide(
                    color: color.withValues(alpha: 0.3),
                    width: 1,
                  )
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: () => _showContentSelectionSheet(context, topicItem, isDark),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: topicItem.imageUrl != null && topicItem.imageUrl!.isNotEmpty
                          ? Image.asset(
                              topicItem.imageUrl!,
                              width: 30,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.image_not_supported_outlined,
                                  color: color.withValues(alpha: 0.5),
                                  size: 30,
                                );
                              },
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      topicItem.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFE8E8F0) : Colors.black87,
                          ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: isDark ? const Color(0xFFB8B8CC) : Colors.grey,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  void _showContentSelectionSheet(BuildContext context, TopicItemModel topicItem, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1F3A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'انتخاب نوع محتوا',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.school, color: Colors.blue),
              ),
              title: Text(
                'آموزش',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'مشاهده ویدیوها و درس‌نامه‌ها',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EducationContentListPage(
                      topicItemId: topicItem.id,
                      topicTitle: topicItem.title,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.quiz, color: Colors.green),
              ),
              title: Text(
                'آزمون',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'حل سوالات تستی و تمرین',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizListPage(
                      topicItemId: topicItem.id,
                      topicTitle: topicItem.title,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String get category => title; // Helper getter
}
