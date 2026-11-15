import 'package:flutter_deck/flutter_deck.dart';
// flutter_deck is built on package:flutter/material.dart, so the app has to
// use the same library rather than package:material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:passkeys_presentation/deck/slides/code_slides.dart';
import 'package:passkeys_presentation/deck/slides/intro_slides.dart';
import 'package:passkeys_presentation/deck/slides/qa_slide.dart';
import 'package:passkeys_presentation/deck/slides/setup_slides.dart';
import 'package:passkeys_presentation/shared/brand.dart';

/// The slides. The last one is the live Q&A.
class DeckApp extends StatelessWidget {
  const DeckApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterDeckThemeData.fromTheme(Brand.theme);
    return FlutterDeckApp(
      themeMode: ThemeMode.dark,
      lightTheme: theme,
      darkTheme: theme,
      configuration: FlutterDeckConfiguration(
        background: const FlutterDeckBackgroundConfiguration(
          light: FlutterDeckBackground.solid(Brand.background),
          dark: FlutterDeckBackground.gradient(
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1C1C1C), Color(0xFF14261D)],
            ),
          ),
        ),
        footer: const FlutterDeckFooterConfiguration(showSlideNumbers: true),
        progressIndicator: const FlutterDeckProgressIndicator.solid(
          color: Brand.green,
          backgroundColor: Brand.surface,
        ),
        slideSize: FlutterDeckSlideSize.fromAspectRatio(
          aspectRatio: const FlutterDeckAspectRatio.ratio16x9(),
          resolution: const FlutterDeckResolution.fhd(),
        ),
        transition: const FlutterDeckTransition.fade(),
      ),
      slides: const [
        TitleSlide(),
        ProblemSlide(),
        WhatIsAPasskeySlide(),
        RegistrationSlide(),
        AuthenticationSlide(),
        WhoDoesWhatSlide(),
        DashboardSetupSlide(),
        PlatformSetupSlide(),
        InstallSlide(),
        RegisterSlide(),
        SignInSlide(),
        ErrorsSlide(),
        UnderTheHoodSlide(),
        ManageSlide(),
        GotchasSlide(),
        ThisDemoSlide(),
        QaSlide(),
      ],
    );
  }
}
