import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable action button for AppBar to toggle search open/closed.
class SearchAppBarAction extends StatelessWidget {
  final bool isSearching;
  final VoidCallback onPressed;
  final Color? color;
  final String? searchTooltip;
  final String? closeTooltip;

  const SearchAppBarAction({
    super.key,
    required this.isSearching,
    required this.onPressed,
    this.color,
    this.searchTooltip,
    this.closeTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = color ??
        (isDark ? AppColors.textPrimaryDark : AppColors.onPrimary);

    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(
          isSearching ? Icons.close : Icons.search,
          key: ValueKey(isSearching),
          color: iconColor,
        ),
      ),
      tooltip: isSearching
          ? (closeTooltip ?? 'بستن جستجو')
          : (searchTooltip ?? 'جستجو'),
      onPressed: onPressed,
    );
  }
}

/// Animated search bar container for Box layouts.
class AppSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Animation<double> animation;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool hasQuery;
  final String hintText;
  final EdgeInsetsGeometry padding;

  const AppSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.animation,
    required this.onChanged,
    required this.onClear,
    required this.hasQuery,
    this.hintText = 'جستجو...',
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 4),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizeTransition(
      sizeFactor: animation,
      alignment: Alignment.topCenter,
      child: Padding(
        padding: padding,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? AppColors.searchShadowDark
                    : AppColors.searchShadowLight,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isDark
                  ? AppColors.searchBarBorderDark
                  : AppColors.searchBarBorderLight,
              width: 1.2,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: isDark
                    ? AppColors.searchIconDark
                    : AppColors.textTertiaryLight,
                fontSize: 15,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: isDark
                    ? AppColors.searchIconDark
                    : AppColors.searchIconLight,
              ),
              suffixIcon: hasQuery
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: isDark
                            ? AppColors.searchIconDark
                            : AppColors.textTertiaryLight,
                        size: 20,
                      ),
                      onPressed: () {
                        controller.clear();
                        onClear();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sliver wrapper for [AppSearchBar] to be placed directly in [CustomScrollView].
class SliverAppSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Animation<double> animation;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool hasQuery;
  final String hintText;
  final EdgeInsetsGeometry padding;

  const SliverAppSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.animation,
    required this.onChanged,
    required this.onClear,
    required this.hasQuery,
    this.hintText = 'جستجو...',
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 4),
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AppSearchBar(
        controller: controller,
        focusNode: focusNode,
        animation: animation,
        onChanged: onChanged,
        onClear: onClear,
        hasQuery: hasQuery,
        hintText: hintText,
        padding: padding,
      ),
    );
  }
}

/// Highlights occurrences of [query] within [text].
class HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultStyle = style ??
        TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: isDark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
          fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
        );

    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      return Text(
        text,
        style: defaultStyle,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      );
    }

    final lowerText = text.toLowerCase();
    final matchIndex = lowerText.indexOf(cleanQuery);

    if (matchIndex == -1) {
      return Text(
        text,
        style: defaultStyle,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      );
    }

    final before = text.substring(0, matchIndex);
    final match = text.substring(matchIndex, matchIndex + cleanQuery.length);
    final after = text.substring(matchIndex + cleanQuery.length);

    return RichText(
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      text: TextSpan(
        style: defaultStyle,
        children: [
          TextSpan(text: before),
          TextSpan(
            text: match,
            style: defaultStyle.copyWith(
              backgroundColor: isDark
                  ? AppColors.searchHighlightDark
                  : AppColors.searchHighlightLight,
              color: isDark
                  ? AppColors.searchHighlightTextDark
                  : AppColors.searchHighlightTextLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }
}

/// Reusable Empty State widget when search yields no matches.
class SearchEmptyState extends StatelessWidget {
  final String query;
  final String title;
  final String? subtitle;

  const SearchEmptyState({
    super.key,
    required this.query,
    this.title = 'نتیجه‌ای یافت نشد',
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 72,
              color: isDark
                  ? AppColors.searchBarBorderDark
                  : AppColors.dividerLight,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle ?? '«$query» پیدا نشد',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sliver wrapper for [SearchEmptyState].
class SliverSearchEmptyState extends StatelessWidget {
  final String query;
  final String title;
  final String? subtitle;

  const SliverSearchEmptyState({
    super.key,
    required this.query,
    this.title = 'نتیجه‌ای یافت نشد',
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: SearchEmptyState(
        query: query,
        title: title,
        subtitle: subtitle,
      ),
    );
  }
}
