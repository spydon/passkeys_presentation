import 'package:flutter_deck/flutter_deck.dart';
// flutter_deck is built on package:flutter/material.dart, so the app has to
// use the same library rather than package:material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:passkeys_presentation/shared/brand.dart';

/// A code listing sized for a 1080p slide.
class SlideCode extends StatelessWidget {
  const SlideCode({
    required this.code,
    this.fileName,
    this.language = 'dart',
    this.highlightedLines = const [],
    this.fontSize = 28,
    super.key,
  });

  final String code;
  final String? fileName;
  final String language;
  final List<int> highlightedLines;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return FlutterDeckCodeHighlightTheme(
      data: FlutterDeckCodeHighlightTheme.of(context).copyWith(
        backgroundColor: Brand.surface,
        textStyle: TextStyle(
          fontFamily: 'monospace',
          fontSize: fontSize,
          height: 1.4,
        ),
      ),
      child: FlutterDeckCodeHighlight(
        code: code,
        fileName: fileName,
        language: language,
        highlightedLines: highlightedLines,
      ),
    );
  }
}

/// A numbered step of a ceremony, revealed with the slide steps.
class CeremonyStep extends StatelessWidget {
  const CeremonyStep({
    required this.number,
    required this.title,
    required this.text,
    required this.visible,
    super.key,
  });

  final int number;
  final String title;
  final String text;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: visible ? 1 : 0,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 28),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Brand.green,
              child: Text(
                '$number',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 28),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 30,
                      color: Brand.mutedText,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A rounded box with an icon, a title and a short description.
class InfoTile extends StatelessWidget {
  const InfoTile({
    required this.icon,
    required this.title,
    required this.text,
    this.highlighted = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String text;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Brand.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: highlighted ? Brand.green : Brand.surfaceHigh,
          width: highlighted ? 3 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 64, color: Brand.green),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 28,
              color: Brand.mutedText,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

/// A bullet point with optional sub-bullets, for [SteppedBulletList].
class Bullet {
  const Bullet(this.text, {this.subBullets = const []});

  final String text;
  final List<String> subBullets;
}

/// A bullet list revealed one bullet per slide step, like
/// [FlutterDeckBulletList] with `useSteps`, but with sub-bullets.
class SteppedBulletList extends StatelessWidget {
  const SteppedBulletList({required this.bullets, super.key});

  final List<Bullet> bullets;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterDeckBulletListTheme.of(context);
    final style = theme.textStyle?.copyWith(color: theme.color);
    final subStyle = style?.copyWith(
      fontSize: (style.fontSize ?? 44) * 0.75,
      color: Brand.mutedText,
    );
    return FlutterDeckSlideStepsBuilder(
      builder: (context, step) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, bullet) in bullets.indexed)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: index < step ? 1 : 0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BulletRow(marker: '•', text: bullet.text, style: style),
                    for (final sub in bullet.subBullets)
                      Padding(
                        padding: const EdgeInsets.only(left: 56, top: 6),
                        child: _BulletRow(
                          marker: '–',
                          text: sub,
                          style: subStyle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({required this.marker, required this.text, this.style});

  final String marker;
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(marker, style: style),
        const SizedBox(width: 20),
        Expanded(child: Text(text, style: style)),
      ],
    );
  }
}
