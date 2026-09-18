import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// Returns true if the string is purely mathematical (does not contain Persian/Arabic text).
bool isMathContent(String content) {
  // Unicode ranges for Arabic (0600-06FF) and Persian extended (FB50-FDFF, FE70-FEFF)
  final persianArabicRegex = RegExp(r'[\u0600-\u06FF\uFB50-\uFDFF\uFE70-\uFEFF]');
  return !persianArabicRegex.hasMatch(content);
}

/// Cleans Persian/Arabic text by stripping LaTeX markup such as \text{}, \quad, \implies, etc.
String cleanLatexForPersian(String input) {
  var res = input;
  // 1. Remove \text{...} wrappers but keep inner content
  res = res.replaceAllMapped(RegExp(r'\\text\{([^}]*)\}'), (m) => m.group(1) ?? '');
  // 2. Map implication and arrows to readable RTL arrows or symbols
  res = res.replaceAll(RegExp(r'\\(?:implies|Longrightarrow|Rightarrow)'), ' ⟵ ');
  res = res.replaceAll(RegExp(r'\\(?:rightarrow|to)'), ' ← ');
  res = res.replaceAllMapped(RegExp(r'\\xrightarrow\{([^}]*)\}'), (m) {
    final inner = cleanLatexForPersian(m.group(1) ?? '');
    return ' ──($inner)──> ';
  });
  // 3. Spacers
  res = res.replaceAll(r'\qquad', '   ');
  res = res.replaceAll(r'\quad', '  ');
  res = res.replaceAll(r'\,', ' ');
  res = res.replaceAll(r'\;', ' ');
  // 4. Clean extra spaces
  res = res.replaceAll(RegExp(r'[ ]{2,}'), ' ');
  return res.trim();
}

class LatexText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final TextDirection textDirection;

  const LatexText(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.start,
    this.textDirection = TextDirection.rtl,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Regex to match $$$...$$$ or $$...$$ (display math) OR $...$ (inline math)
    final RegExp regex = RegExp(r'\${2,3}([\s\S]+?)\${2,3}|\$([^\$]+?)\$');
    final List<InlineSpan> spans = [];

    text.splitMapJoin(
      regex,
      onMatch: (Match match) {
        final isDisplay = match.group(1) != null;
        var mathContent = (isDisplay ? match.group(1) : match.group(2))?.trim() ?? '';
        mathContent = mathContent.replaceAll(RegExp(r'^\$+|\$+$'), '').trim();

        // If content is Persian/Arabic text, render as plain RTL text span
        if (!isMathContent(mathContent)) {
          final clean = cleanLatexForPersian(mathContent);
          spans.add(
            TextSpan(
              text: clean,
              style: style,
            ),
          );
          return match.group(0)!;
        }

        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.0,
                  vertical: isDisplay ? 4.0 : 0.0,
                ),
                child: Math.tex(
                  mathContent,
                  textStyle: style?.copyWith(fontFamily: 'SansSerif'),
                  mathStyle: isDisplay ? MathStyle.display : MathStyle.text,
                  onErrorFallback: (err) => Text(
                    match.group(0) ?? mathContent,
                    style: style,
                  ),
                ),
              ),
            ),
          ),
        );
        return match.group(0)!;
      },
      onNonMatch: (String nonMatch) {
        if (nonMatch.isNotEmpty) {
          var cleanText = nonMatch
              .replaceAll(r'\r\n', '\n')
              .replaceAll(r'\\n', '\n')
              .replaceAll(r'\n', '\n')
              .replaceAll('\r', '');
          // Remove stray lone $ or \$ that might come from malformed inputs
          cleanText = cleanText.replaceAll(r'\$', '');
          if (cleanText.isNotEmpty) {
            spans.add(
              TextSpan(
                text: cleanText,
                style: style,
              ),
            );
          }
        }
        return nonMatch;
      },
    );

    final defaultStyle = DefaultTextStyle.of(context).style;
    final effectiveStyle = defaultStyle.merge(style);

    return Text.rich(
      TextSpan(children: spans, style: effectiveStyle),
      textAlign: textAlign,
      textDirection: textDirection,
    );
  }
}

