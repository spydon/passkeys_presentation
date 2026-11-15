// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passkeys_presentation/deck/slides/code_slides.dart';
import 'package:passkeys_presentation/deck/slides/intro_slides.dart';
import 'package:passkeys_presentation/deck/slides/setup_slides.dart';
import 'package:passkeys_presentation/deck/deck_app.dart';

void main() {
  const slides = <FlutterDeckSlideWidget>[
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
  ];

  for (final slide in slides) {
    testWidgets('${slide.configuration!.route} renders without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        FlutterDeckApp(
          themeMode: ThemeMode.dark,
          lightTheme: DeckApp.theme,
          darkTheme: DeckApp.theme,
          configuration: DeckApp.configuration,
          slides: [slide],
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
