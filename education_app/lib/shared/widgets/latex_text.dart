import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

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
    // 1. Unescape newlines (\r\n, \n, \r)
    final normalizedText = text
        .replaceAll(r'\r\n', '\n')
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\r', '\n');

    // 2. Regex to match $$...$$ (display math) OR $...$ (inline math)
    final RegExp regex = RegExp(r'\$\$([\s\S]+?)\$\$|\$([^\$]+?)\$');
    final List<InlineSpan> spans = [];

    normalizedText.splitMapJoin(
      regex,
      onMatch: (Match match) {
        final isDisplay = match.group(1) != null;
        final mathContent = (isDisplay ? match.group(1) : match.group(2))?.trim() ?? '';

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
          spans.add(
            TextSpan(
              text: nonMatch,
              style: style,
            ),
          );
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

