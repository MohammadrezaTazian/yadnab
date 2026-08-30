import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:education_app/l10n/app_localizations.dart';
import 'package:education_app/features/home/data/models/package_model.dart';
import 'package:education_app/injection_container.dart';
import 'package:education_app/features/topics/presentation/pages/topics_page.dart';
import 'package:education_app/shared/widgets/app_drawer.dart';
import 'package:education_app/shared/theme/app_colors.dart';
import 'package:education_app/shared/widgets/app_search.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeBloc>()..add(LoadPackagesEvent()),
      child: const _HomePageContent(),
    );
  }
}

class _HomePageContent extends StatefulWidget {
  const _HomePageContent();

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent>
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

    return BlocConsumer<HomeBloc, HomeState>(
      listenWhen: (previous, current) {
        if (previous is HomeLoaded && current is HomeLoaded) {
          return previous.isSearching != current.isSearching;
        }
        return current is HomeLoaded && current.isSearching;
      },
      listener: (context, state) {
        if (state is HomeLoaded) {
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
        final isSearching = state is HomeLoaded && state.isSearching;
        final searchQuery = state is HomeLoaded ? state.searchQuery : '';

        return Scaffold(
          drawer: const AppDrawer(),
          body: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
            ),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  actions: [
                    SearchAppBarAction(
                      isSearching: isSearching,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.onPrimary,
                      onPressed: () {
                        context.read<HomeBloc>().add(ToggleHomeSearchVisibilityEvent());
                      },
                    ),
                    const SizedBox(width: 4),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      AppLocalizations.of(context)!.educationAssistant,
                      style: TextStyle(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: isDark
                            ? AppColors.headerGradientDark
                            : AppColors.headerGradientLight,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.school_rounded,
                              size: 60,
                              color: AppColors.onPrimary.withValues(alpha: 0.9),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              AppLocalizations.of(context)!.welcomeBack,
                              style: TextStyle(
                                color: AppColors.onPrimary.withValues(alpha: 0.7),
                                fontSize: 16,
                              ),
                            ),
                          ],
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
                  hintText: 'جستجوی دوره‌ها و پکیج‌ها...',
                  onChanged: (query) {
                    context.read<HomeBloc>().add(SearchPackagesEvent(query));
                  },
                  onClear: () {
                    context.read<HomeBloc>().add(ClearPackagesSearchEvent());
                  },
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.selectGrade,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (state is HomeLoading)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (state is HomeError)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        color: AppColors.error.withValues(alpha: 0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(Icons.error_rounded, color: AppColors.error),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Error: ${state.message}',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.refresh_rounded, color: colorScheme.primary),
                                onPressed: () {
                                  context.read<HomeBloc>().add(LoadPackagesEvent());
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                else if (state is HomeLoaded)
                  if (state.filteredPackages.isEmpty && searchQuery.isNotEmpty)
                    SliverSearchEmptyState(
                      query: searchQuery,
                      subtitle: '«$searchQuery» در دوره‌ها پیدا نشد',
                    )
                  else if (state.packages.isEmpty)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: colorScheme.outline,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No packages available',
                                style: textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final package = state.filteredPackages[index];
                            return _buildPackageCard(
                              context,
                              package,
                              _getIconForCategory(package.category),
                              _getColorForCategory(package.category, colorScheme),
                              colorScheme,
                              textTheme,
                              searchQuery,
                            );
                          },
                          childCount: state.filteredPackages.length,
                        ),
                      ),
                    )
                else
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'grade6':
      case 'grade9':
        return Icons.school_rounded;
      case 'mathphysics':
        return Icons.calculate_rounded;
      case 'experimental':
        return Icons.science_rounded;
      case 'humanities':
        return Icons.menu_book_rounded;
      default:
        return Icons.book_rounded;
    }
  }

  Color _getColorForCategory(String category, ColorScheme colorScheme) {
    switch (category.toLowerCase()) {
      case 'grade6':
        return AppColors.accentLight;
      case 'grade9':
        return colorScheme.primary;
      case 'mathphysics':
        return colorScheme.secondary;
      case 'experimental':
        return AppColors.success;
      case 'humanities':
        return AppColors.error;
      default:
        return colorScheme.tertiary;
    }
  }

  Widget _buildPackageCard(
    BuildContext context,
    PackageModel package,
    IconData icon,
    Color color,
    ColorScheme colorScheme,
    TextTheme textTheme,
    String searchQuery,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TopicsPage(
                packageId: package.id,
                title: package.title,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HighlightedText(
                      text: package.title,
                      query: searchQuery,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (package.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      HighlightedText(
                        text: package.description,
                        query: searchQuery,
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: colorScheme.outline,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


