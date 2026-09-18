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

  static String _unescapeOutsideMath(String input) {
    // Match $$$...$$$, $$...$$, or $...$
    final mathRegex = RegExp(r'\${2,3}[\s\S]+?\${2,3}|\$[^\$]+?\$');
    return input.splitMapJoin(
      mathRegex,
      onMatch: (m) => m.group(0)!, // Keep all LaTeX math 100% intact!
      onNonMatch: (nonMath) {
        return nonMath
            .replaceAll(r'\r\n', '\n')
            .replaceAll(r'\\n', '\n')
            .replaceAll(r'\n', '\n')
            .replaceAll('\r', '');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (content.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final normalized = _unescapeOutsideMath(content);

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

    // Regex to extract $$...$$ or $$$...$$$ display math blocks
    final RegExp displayMathRegex = RegExp(r'\${2,3}([\s\S]+?)\${2,3}');
    final matches = displayMathRegex.allMatches(text);

    int lastIndex = 0;

    for (final match in matches) {
      // 1. Text before display math
      if (match.start > lastIndex) {
        final textBefore = text.substring(lastIndex, match.start);
        _addTextLines(context, textBefore, widgets, textTheme, colorScheme);
      }

      // 2. The display math block itself
      var mathContent = match.group(1)?.trim() ?? '';
      mathContent = mathContent
          .replaceAll(RegExp(r'^\$+|\$+$'), '')
          .replaceAll(r'\\n', '\n')
          .trim();

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

      if (line.isEmpty || line == r'$' || line == r'\$' || line == r'$$' || line == r'$$$') {
        // Subtle paragraph spacing for empty lines only
        if (line.isEmpty) {
          widgets.add(const SizedBox(height: 10));
        }
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
    if (line.endsWith(':')) {
      final stripped = line.replaceAll(RegExp(r'\$[^\$]*\$'), 'X');
      if (stripped.length < 45) return true;
    }
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
              child: LatexText(
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
            child: LatexText(
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
    // If the formula contains Persian or Arabic characters, use our smart Persian card renderer
    final hasPersianArabic = !isMathContent(mathContent);

    if (hasPersianArabic) {
      return _buildPersianMathCard(context, mathContent, colorScheme);
    }

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

  Widget _buildPersianMathCard(
    BuildContext context,
    String mathContent,
    ColorScheme colorScheme,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    // 1. Check if this is a flow sequence with arrows (e.g. \implies, \rightarrow, \xrightarrow{})
    final arrowRegex = RegExp(r'(\\implies|\\Longrightarrow|\\Rightarrow|\\rightarrow|\\to|\\xrightarrow\{[^}]*\})');
    if (arrowRegex.hasMatch(mathContent)) {
      return _buildFlowSequenceCard(context, mathContent, colorScheme, textTheme, isDark);
    }

    // 2. Check if this is a Quran verse or quote
    final isQuote = mathContent.contains('«') ||
        mathContent.contains('سوره') ||
        mathContent.contains('آیه') ||
        mathContent.contains('حدیث');
    if (isQuote) {
      return _buildQuoteCard(context, mathContent, colorScheme, textTheme, isDark);
    }

    // 3. Mixed math + Persian (e.g. x >= 5 \quad \text{یا} \quad x <= -5)
    return _buildMixedMathCard(context, mathContent, colorScheme, textTheme, isDark);
  }

  Widget _buildFlowSequenceCard(
    BuildContext context,
    String mathContent,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isDark,
  ) {
    final arrowRegex = RegExp(r'(\\implies|\\Longrightarrow|\\Rightarrow|\\rightarrow|\\to|\\xrightarrow\{[^}]*\})');
    final matches = arrowRegex.allMatches(mathContent).toList();

    final List<Widget> flowItems = [];
    int lastEnd = 0;

    for (int i = 0; i < matches.length; i++) {
      final match = matches[i];
      // Text node before arrow
      final rawNode = mathContent.substring(lastEnd, match.start).trim();
      final nodeText = cleanLatexForPersian(rawNode);
      if (nodeText.isNotEmpty) {
        flowItems.add(_buildFlowNode(nodeText, colorScheme, textTheme, isDark));
      }

      // The arrow itself
      final arrowStr = match.group(0)!;
      String? arrowLabel;
      final xArrowMatch = RegExp(r'\\xrightarrow\{([^}]*)\}').firstMatch(arrowStr);
      if (xArrowMatch != null) {
        arrowLabel = cleanLatexForPersian(xArrowMatch.group(1) ?? '');
      }

      flowItems.add(_buildFlowArrow(arrowLabel, colorScheme, textTheme));
      lastEnd = match.end;
    }

    // Last node after the last arrow
    if (lastEnd < mathContent.length) {
      final rawNode = mathContent.substring(lastEnd).trim();
      final nodeText = cleanLatexForPersian(rawNode);
      if (nodeText.isNotEmpty) {
        flowItems.add(_buildFlowNode(nodeText, colorScheme, textTheme, isDark));
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 10,
            children: flowItems,
          ),
        ),
      ),
    );
  }

  Widget _buildFlowNode(
    String text,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.primary.withValues(alpha: 0.15)
            : colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildFlowArrow(
    String? label,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    if (label != null && label.isNotEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 10.5,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Icon(
            Icons.arrow_back_rounded,
            size: 20,
            color: colorScheme.primary,
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Icon(
        Icons.arrow_back_rounded,
        size: 20,
        color: colorScheme.primary.withValues(alpha: 0.8),
      ),
    );
  }

  Widget _buildQuoteCard(
    BuildContext context,
    String mathContent,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isDark,
  ) {
    final cleanText = cleanLatexForPersian(mathContent);

    // Try to extract citation if in parentheses: (سوره ...)
    String mainText = cleanText;
    String citation = '';

    final citationMatch = RegExp(r'\((سوره[^\)]+)\)').firstMatch(cleanText);
    if (citationMatch != null) {
      citation = citationMatch.group(0)!;
      mainText = cleanText.replaceFirst(citation, '').trim();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.primary.withValues(alpha: 0.08)
            : colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Text(
              mainText,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                height: 2.1,
                color: colorScheme.onSurface,
              ),
            ),
            if (citation.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
                      : colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  citation,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMixedMathCard(
    BuildContext context,
    String mathContent,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isDark,
  ) {
    // Split by \text{...}
    final textRegex = RegExp(r'\\text\{([^}]*)\}');
    final matches = textRegex.allMatches(mathContent).toList();

    if (matches.isEmpty) {
      // Pure Persian text without \text{}
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
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
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            cleanLatexForPersian(mathContent),
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              height: 1.9,
              fontSize: 15.0,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      );
    }

    final List<Widget> segments = [];
    int lastEnd = 0;

    for (int i = 0; i < matches.length; i++) {
      final match = matches[i];
      // Math before \text{}
      if (match.start > lastEnd) {
        final rawMath = mathContent.substring(lastEnd, match.start).trim();
        final cleanMath = rawMath
            .replaceAll(r'\qquad', ' ')
            .replaceAll(r'\quad', ' ')
            .replaceAll(r'\,', ' ')
            .replaceAll(r'\;', ' ')
            .trim();
        if (cleanMath.isNotEmpty) {
          segments.add(
            Directionality(
              textDirection: TextDirection.ltr,
              child: Math.tex(
                cleanMath,
                textStyle: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurface,
                  fontFamily: 'SansSerif',
                ),
                mathStyle: MathStyle.display,
                onErrorFallback: (err) => Text(cleanMath),
              ),
            ),
          );
        }
      }

      // The Persian text inside \text{}
      final persianText = match.group(1)?.trim() ?? '';
      if (persianText.isNotEmpty) {
        segments.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Text(
              persianText,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
        );
      }

      lastEnd = match.end;
    }

    // Math after last \text{}
    if (lastEnd < mathContent.length) {
      final rawMath = mathContent.substring(lastEnd).trim();
      final cleanMath = rawMath
          .replaceAll(r'\qquad', ' ')
          .replaceAll(r'\quad', ' ')
          .replaceAll(r'\,', ' ')
          .replaceAll(r'\;', ' ')
          .trim();
      if (cleanMath.isNotEmpty) {
        segments.add(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Math.tex(
              cleanMath,
              textStyle: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface,
                fontFamily: 'SansSerif',
              ),
              mathStyle: MathStyle.display,
              onErrorFallback: (err) => Text(cleanMath),
            ),
          ),
        );
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
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
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: segments,
            ),
          ),
        ),
      ),
    );
  }
}
