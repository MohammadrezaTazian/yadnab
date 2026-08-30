import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:education_app/features/topics/presentation/bloc/topic_bloc.dart';
import 'package:education_app/features/topics/presentation/bloc/topic_event.dart';
import 'package:education_app/features/topics/presentation/bloc/topic_state.dart';
import 'package:education_app/features/topics/domain/entities/topic.dart';
import 'package:education_app/injection_container.dart';
import 'package:education_app/features/quiz/presentation/pages/quiz_list_page.dart';
import 'package:education_app/features/education/presentation/pages/education_content_list_page.dart';
import 'package:education_app/shared/theme/app_colors.dart';
import 'package:education_app/shared/widgets/app_search.dart';

class TopicsPage extends StatelessWidget {
  final int packageId;
  final String title;

  const TopicsPage({
    super.key,
    required this.packageId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TopicBloc>()..add(LoadTopics(packageId)),
      child: _TopicsPageContent(packageId: packageId, title: title),
    );
  }
}

class _TopicsPageContent extends StatefulWidget {
  final int packageId;
  final String title;

  const _TopicsPageContent({required this.packageId, required this.title});

  @override
  State<_TopicsPageContent> createState() => _TopicsPageContentState();
}

class _TopicsPageContentState extends State<_TopicsPageContent>
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

    return BlocConsumer<TopicBloc, TopicState>(
      listenWhen: (previous, current) {
        if (previous is TopicLoaded && current is TopicLoaded) {
          return previous.isSearching != current.isSearching;
        }
        return current is TopicLoaded && current.isSearching;
      },
      listener: (context, state) {
        if (state is TopicLoaded) {
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
        final isSearching = state is TopicLoaded && state.isSearching;
        final searchQuery = state is TopicLoaded ? state.searchQuery : '';
        final expandedTopicIds =
            state is TopicLoaded ? state.expandedTopicIds : <int>{};

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        AppColors.backgroundDark,
                        AppColors.surfaceDark,
                        AppColors.backgroundDeepDark,
                      ]
                    : [
                        AppColors.backgroundGradientStartLight,
                        AppColors.surfaceLight,
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
                      color: isDark ? AppColors.textPrimaryDark : AppColors.onPrimary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  actions: [
                    SearchAppBarAction(
                      isSearching: isSearching,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.onPrimary,
                      onPressed: () {
                        context.read<TopicBloc>().add(ToggleSearchVisibility());
                      },
                    ),
                    const SizedBox(width: 4),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      widget.title,
                      style: TextStyle(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.onPrimary,
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
                                  AppColors.surfaceDark,
                                  AppColors.cardDark,
                                ]
                              : [
                                  AppColors.appBarGradientStartLight,
                                  AppColors.appBarGradientEndLight,
                                ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.menu_book,
                          size: 60,
                          color: AppColors.iconHeaderOverlay,
                        ),
                      ),
                    ),
                  ),
                ),
                // ---- Search Bar ----
                SliverAppSearchBar(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  animation: _searchBarAnimation,
                  hasQuery: searchQuery.isNotEmpty,
                  hintText: 'جستجوی سرفصل‌ها...',
                  onChanged: (query) {
                    context.read<TopicBloc>().add(SearchTopics(query));
                  },
                  onClear: () {
                    context.read<TopicBloc>().add(ClearSearch());
                  },
                ),
                if (state is TopicLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state is TopicError)
                  SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 60,
                              color: AppColors.errorIcon,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'خطا در بارگذاری سرفصل‌ها',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                context
                                    .read<TopicBloc>()
                                    .add(LoadTopics(widget.packageId));
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('تلاش مجدد'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (state is TopicLoaded)
                  if (state.filteredTopics.isEmpty && searchQuery.isNotEmpty)
                    SliverSearchEmptyState(
                      query: searchQuery,
                      subtitle: '«$searchQuery» در سرفصل‌ها پیدا نشد',
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final topic = state.filteredTopics[index];
                            return _TopicTreeItem(
                              topic: topic,
                              index: index,
                              isDark: isDark,
                              searchQuery: searchQuery,
                              expandedTopicIds: expandedTopicIds,
                              onLeafTap: (t) =>
                                  _showContentSelectionSheet(context, t, isDark),
                            );
                          },
                          childCount: state.filteredTopics.length,
                        ),
                      ),
                    )
                else
                  const SliverFillRemaining(
                    child: Center(
                      child: Text('داده‌ای یافت نشد'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showContentSelectionSheet(
      BuildContext context, Topic topic, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
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
                  color: isDark ? AppColors.onPrimary : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 24),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.educationIconBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.school, color: AppColors.info),
                  ),
                  title: Text(
                    'آموزش',
                    style: TextStyle(
                      color: isDark ? AppColors.onPrimary : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'مشاهده ویدیوها و درس‌نامه‌ها',
                    style: TextStyle(
                      color: isDark ? AppColors.sheetSubtitleDark : AppColors.sheetSubtitleLight,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EducationContentListPage(
                          topicId: topic.id,
                          topicTitle: topic.title,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.quizIconBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.quiz, color: AppColors.success),
                  ),
                  title: Text(
                    'آزمون',
                    style: TextStyle(
                      color: isDark ? AppColors.onPrimary : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'حل سوالات تستی و تمرین',
                    style: TextStyle(
                      color: isDark ? AppColors.sheetSubtitleDark : AppColors.sheetSubtitleLight,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizListPage(
                          topicId: topic.id,
                          topicTitle: topic.title,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _TopicTreeItem
// ---------------------------------------------------------------------------

/// ویجت بازگشتی برای نمایش هر گره در درخت سرفصل‌ها.
///
/// از [ExpansibleController] استفاده می‌کند تا بتواند در [didUpdateWidget]
/// به تغییر [expandedTopicIds] واکنش نشان دهد و گره را باز یا بسته کند.
/// این روش مشکل [initiallyExpanded] را حل می‌کند، چون [initiallyExpanded]
/// فقط یک‌بار هنگام ساخت اولیه ویجت اعمال می‌شود.
class _TopicTreeItem extends StatefulWidget {
  final Topic topic;
  final int index;
  final bool isDark;
  final String searchQuery;
  final Set<int> expandedTopicIds;
  final void Function(Topic topic) onLeafTap;

  const _TopicTreeItem({
    required this.topic,
    required this.index,
    required this.isDark,
    required this.searchQuery,
    required this.expandedTopicIds,
    required this.onLeafTap,
  });

  @override
  State<_TopicTreeItem> createState() => _TopicTreeItemState();
}

class _TopicTreeItemState extends State<_TopicTreeItem> {
  // ExpansibleController جایگزین ExpansionTileController در Flutter 3.31+
  final ExpansibleController _controller = ExpansibleController();

  static const List<Color> _colors = [
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

  bool get _shouldBeExpanded =>
      widget.expandedTopicIds.contains(widget.topic.id);

  @override
  void didUpdateWidget(covariant _TopicTreeItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    final wasExpanded = oldWidget.expandedTopicIds.contains(oldWidget.topic.id);
    final nowExpanded = _shouldBeExpanded;

    // فقط در صورت تغییر وضعیت، expand/collapse را اعمال کن
    if (wasExpanded != nowExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (nowExpanded) {
          _controller.expand();
        } else {
          _controller.collapse();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colors[widget.index % _colors.length];

    if (widget.topic.children.isNotEmpty) {
      return _buildParentNode(color);
    } else {
      return _buildLeafNode(color);
    }
  }

  /// گره والد با ExpansionTile و کنترلر
  Widget _buildParentNode(Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: widget.isDark ? AppColors.cardDark : AppColors.cardLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: widget.isDark
            ? BorderSide(color: color.withValues(alpha: 0.3))
            : BorderSide.none,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          controller: _controller,
          // initiallyExpanded فقط برای اولین بار اعمال می‌شود؛
          // تغییرات بعدی توسط کنترلر در didUpdateWidget مدیریت می‌شوند.
          initiallyExpanded: _shouldBeExpanded,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.folder_open, color: color),
          ),
          title: HighlightedText(
            text: widget.topic.title,
            query: widget.searchQuery,
          ),
          childrenPadding: const EdgeInsets.only(left: 16, bottom: 8),
          children: widget.topic.children
              .asMap()
              .entries
              .map(
                (entry) => _TopicTreeItem(
                  topic: entry.value,
                  index: entry.key,
                  isDark: widget.isDark,
                  searchQuery: widget.searchQuery,
                  expandedTopicIds: widget.expandedTopicIds,
                  onLeafTap: widget.onLeafTap,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  /// گره برگ (بدون فرزند)
  Widget _buildLeafNode(Color color) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (widget.index * 100)),
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
        color: widget.isDark ? AppColors.cardDark : AppColors.cardLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: widget.isDark
              ? BorderSide(
                  color: color.withValues(alpha: 0.3),
                  width: 1,
                )
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: () => widget.onLeafTap(widget.topic),
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
                    child: widget.topic.imageUrl != null &&
                            widget.topic.imageUrl!.isNotEmpty
                        ? Image.asset(
                            widget.topic.imageUrl!,
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
                            '${widget.index + 1}',
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
                  child: HighlightedText(
                    text: widget.topic.title,
                    query: widget.searchQuery,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: widget.isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
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
