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
    // Regex to split by '$'
    // This assumes LaTeX math segments are enclosed in single '$' like "$x+y$"
    // Examples: "This is $x$." -> ["This is ", "x", "."]
    final RegExp regex = RegExp(r'\$([^\$]+)\$');
    final List<InlineSpan> spans = [];

    text.splitMapJoin(
      regex,
      onMatch: (Match match) {
        // This is the math part (content inside $...$)
        final mathContent = match.group(1) ?? '';
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Math.tex(
                mathContent,
                textStyle: style?.copyWith(fontFamily: 'SansSerif'), // Use a standard font for math
                mathStyle: MathStyle.text,
              ),
            ),
          ),
        );
        return match.group(0)!;
      },
      onNonMatch: (String nonMatch) {
        // This is the normal text part
        if (nonMatch.isNotEmpty) {
          spans.add(
            TextSpan(
              text: nonMatch,
              style: style, // Uses the App's default font (Vazir)
            ),
          );
        }
        return nonMatch;
      },
    );

    return RichText(
      text: TextSpan(children: spans),
      textAlign: textAlign,
      textDirection: textDirection,
    );
  }
}
