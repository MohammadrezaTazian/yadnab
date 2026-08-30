import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/app_search.dart';
import '../bloc/education_content_bloc.dart';
import '../bloc/education_content_event.dart';
import '../bloc/education_content_state.dart';
import 'education_content_detail_page.dart';

class EducationContentListPage extends StatelessWidget {
  final int topicId;
  final String topicTitle;

  const EducationContentListPage({
    super.key,
    required this.topicId,
    required this.topicTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<EducationContentBloc>()..add(GetEducationContentsByTopicEvent(topicId)),
      child: _EducationContentListView(topicId: topicId, topicTitle: topicTitle),
    );
  }
}

class _EducationContentListView extends StatefulWidget {
  final int topicId;
  final String topicTitle;

  const _EducationContentListView({required this.topicId, required this.topicTitle});

  @override
  State<_EducationContentListView> createState() => _EducationContentListViewState();
}

class _EducationContentListViewState extends State<_EducationContentListView>
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
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<EducationContentBloc, EducationContentState>(
      listenWhen: (previous, current) {
        if (previous is EducationContentLoaded && current is EducationContentLoaded) {
          return previous.isSearching != current.isSearching;
        }
        return current is EducationContentLoaded && current.isSearching;
      },
      listener: (context, state) {
        if (state is EducationContentLoaded) {
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
        final isSearching = state is EducationContentLoaded && state.isSearching;
        final searchQuery = state is EducationContentLoaded ? state.searchQuery : '';

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.topicTitle),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: IconThemeData(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            actions: [
              SearchAppBarAction(
                isSearching: isSearching,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                onPressed: () {
                  context.read<EducationContentBloc>().add(ToggleEducationContentSearchVisibilityEvent());
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
                hintText: 'جستجوی درس‌ها یا مدرس...',
                onChanged: (query) {
                  context.read<EducationContentBloc>().add(SearchEducationContentEvent(query));
                },
                onClear: () {
                  context.read<EducationContentBloc>().add(ClearEducationContentSearchEvent());
                },
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (state is EducationContentLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is EducationContentError) {
                      return Center(child: Text(state.message));
                    } else if (state is EducationContentLoaded) {
                      final contents = state.filteredContents;

                      if (contents.isEmpty) {
                        if (searchQuery.isNotEmpty) {
                          return SearchEmptyState(
                            query: searchQuery,
                            subtitle: '«$searchQuery» در آموزش‌ها پیدا نشد',
                          );
                        }
                        return const Center(child: Text('آموزشی برای این مورد یافت نشد'));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: contents.length,
                        itemBuilder: (context, index) {
                          final content = contents[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Icon(
                                content.mediaType == 'Video' ? Icons.play_circle_fill : Icons.article,
                                color: Colors.blue,
                              ),
                              title: HighlightedText(
                                text: content.title,
                                query: searchQuery,
                              ),
                              subtitle: HighlightedText(
                                text: content.teacherName ?? 'نامشخص',
                                query: searchQuery,
                                style: textTheme.bodySmall?.copyWith(
                                  color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
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
                                  bloc.add(GetEducationContentsByTopicEvent(widget.topicId));
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
              ),
            ],
          ),
        );
      },
    );
  }
}

