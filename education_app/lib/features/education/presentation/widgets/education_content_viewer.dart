import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:education_app/shared/widgets/latex_text.dart';

/// A rich educational content viewer that parses multi-section text,
/// unescapes newlines, renders block LaTeX formulas ($$...$$) in dedicated
/// scrollable cards, highlights headings and lists, and handles inline LaTeX ($...$).
class EducationContentViewer extends StatelessWidget {
  final String content;
  final TextStyle? textStyle;

  const EducationContentViewer({
    super.key,
    required this.content,
    this.textStyle,
  });

  static const Set<String> _knownHeadings = {
    'مقدمه',
    'مفاهیم اصلی',
    'فرمول‌ها و روابط علمی',
    'فرمولها و روابط علمی',
    'فرمول‌ها',
    'فرمولها',
    'مثال حل‌شده',
    'مثال حلشده',
    'مثال',
    'نکات کلیدی و کنکوری',
    'نکات کلیدی',
    'نکات کنکوری',
    'کاربردها',
    'کاربردها و اهمیت',
    'جمع‌بندی',
    'جمعبندی',
    'نتیجه‌گیری',
    'سوال:',
    'حل:',
  };

  @override
  Widget build(BuildContext context) {
    if (content.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final normalized = content
        .replaceAll(r'\r\n', '\n')
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\r', '\n');

    final blocks = _parseBlocks(context, normalized);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: blocks,
    );
  }

  List<Widget> _parseBlocks(BuildContext context, String text) {
    final List<Widget> widgets = [];
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Regex to extract $$...$$ display math blocks
    final RegExp displayMathRegex = RegExp(r'\$\$([\s\S]+?)\$\$');
    final matches = displayMathRegex.allMatches(text);

    int lastIndex = 0;

    for (final match in matches) {
      // 1. Text before display math
      if (match.start > lastIndex) {
        final textBefore = text.substring(lastIndex, match.start);
        _addTextLines(context, textBefore, widgets, textTheme, colorScheme);
      }

      // 2. The display math block itself
      final mathContent = match.group(1)?.trim() ?? '';
      if (mathContent.isNotEmpty) {
        widgets.add(_buildMathCard(context, mathContent, colorScheme));
      }

      lastIndex = match.end;
    }

    // 3. Text after last display math
    if (lastIndex < text.length) {
      final remainingText = text.substring(lastIndex);
      _addTextLines(context, remainingText, widgets, textTheme, colorScheme);
    }

    return widgets;
  }

  void _addTextLines(
    BuildContext context,
    String textBlock,
    List<Widget> widgets,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    final lines = textBlock.split('\n');
    final numberedRegex = RegExp(r'^([۰-۹0-9]+)[\.\-]\s*(.*)$');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.isEmpty) {
        // Subtle paragraph spacing
        widgets.add(const SizedBox(height: 10));
        continue;
      }

      // Heading Check (Markdown #, known heading, or question/solution keywords)
      if (_isHeading(line)) {
        final cleanTitle = line.replaceFirst(RegExp(r'^#+\s*'), '').trim();
        widgets.add(_buildHeading(context, cleanTitle, colorScheme, textTheme));
        continue;
      }

      // Bullet List Check (- or * or •)
      if (line.startsWith('- ') || line.startsWith('* ') || line.startsWith('• ')) {
        final itemText = line.substring(2).trim();
        widgets.add(_buildBulletItem(context, itemText, colorScheme, textTheme));
        continue;
      }

      // Numbered List Check (۱. or 1.)
      final numMatch = numberedRegex.firstMatch(line);
      if (numMatch != null) {
        final number = numMatch.group(1)!;
        final itemText = numMatch.group(2)!.trim();
        widgets.add(_buildNumberedItem(context, number, itemText, colorScheme, textTheme));
        continue;
      }

      // Regular Paragraph with inline LaTeX support
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: LatexText(
            line,
            style: textStyle ??
                textTheme.bodyLarge?.copyWith(
                  height: 1.85,
                  fontSize: 15.0,
                ),
          ),
        ),
      );
    }
  }

  bool _isHeading(String line) {
    if (line.startsWith('#')) return true;
    if (_knownHeadings.contains(line)) return true;
    if (line.endsWith(':') && line.length < 35) return true;
    return false;
  }

  Widget _buildHeading(
    BuildContext context,
    String title,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final isSubHeading = title == 'سوال:' || title == 'حل:';

    if (isSubHeading) {
      final isQuestion = title.startsWith('سوال');
      return Container(
        margin: const EdgeInsets.only(top: 14, bottom: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isQuestion
                    ? Colors.amber.withValues(alpha: 0.15)
                    : Colors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  color: isQuestion ? Colors.amber[800] : Colors.green[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletItem(
    BuildContext context,
    String itemText,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, right: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 9, left: 10),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: LatexText(
              itemText,
              style: textStyle ??
                  textTheme.bodyLarge?.copyWith(
                    height: 1.85,
                    fontSize: 15.0,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedItem(
    BuildContext context,
    String number,
    String itemText,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, right: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4, left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              number,
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: LatexText(
              itemText,
              style: textStyle ??
                  textTheme.bodyLarge?.copyWith(
                    height: 1.85,
                    fontSize: 15.0,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMathCard(
    BuildContext context,
    String mathContent,
    ColorScheme colorScheme,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Math.tex(
              mathContent,
              textStyle: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface,
                fontFamily: 'SansSerif',
              ),
              mathStyle: MathStyle.display,
              onErrorFallback: (err) => SelectableText(
                '\$\$$mathContent\$\$',
                style: TextStyle(
                  color: colorScheme.error,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
