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
