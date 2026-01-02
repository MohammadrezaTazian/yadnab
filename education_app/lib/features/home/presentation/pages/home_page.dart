import 'package:flutter/material.dart';
import 'package:education_app/l10n/app_localizations.dart';
import 'package:education_app/core/services/api_service.dart';
import 'package:education_app/features/home/data/models/product_model.dart';
import 'package:education_app/injection_container.dart';
import 'package:education_app/features/course_topics/presentation/pages/course_topics_page.dart';
import 'package:education_app/shared/widgets/app_drawer.dart';
import 'package:education_app/shared/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = sl<ApiService>();
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final products = await _apiService.getProducts();

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.selectGrade,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_isLoading)
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
                    const SizedBox(height: 16),
                    if (_error != null)
                      Card(
                        color: AppColors.error.withValues(alpha: 0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(Icons.error_rounded, color: AppColors.error),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Error: $_error',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.refresh_rounded, color: colorScheme.primary),
                                onPressed: _loadProducts,
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (!_isLoading && _products.isEmpty && _error == null)
                      Center(
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
                                'No products available',
                                style: textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ..._products.map((product) => _buildProductCard(
                          context,
                          product,
                          _getIconForCategory(product.category),
                          _getColorForCategory(product.category, colorScheme),
                          colorScheme,
                          textTheme,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildProductCard(
    BuildContext context,
    ProductModel product,
    IconData icon,
    Color color,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CourseTopicsPage(
                category: product.category,
                title: product.title,
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
                    Text(
                      product.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (product.description.isNotEmpty)
                      Text(
                        product.description,
                        style: textTheme.bodySmall,
                      ),
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

