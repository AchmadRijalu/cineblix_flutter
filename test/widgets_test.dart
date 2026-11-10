import 'package:cineblix_flutter/common/commons.dart';
import 'package:cineblix_flutter/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('theme', () {
    test('exposes the palette, text styles and weights', () {
      expect([
        whiteColor,
        blackColor,
        greyColor,
        lightBackgroundColor,
        darkBackgroundColor,
        primaryColor,
        primaryDarkColor,
        redColor,
        greenColor,
      ], hasLength(9));
      expect(whiteTextStyle.color, whiteColor);
      expect(primaryDarkTextStyle.color, primaryDarkColor);
      expect(
        [light, regular, medium, semiBold, bold, extraBold, black],
        [
          FontWeight.w300,
          FontWeight.w400,
          FontWeight.w500,
          FontWeight.w600,
          FontWeight.w700,
          FontWeight.w800,
          FontWeight.w900,
        ],
      );
    });
  });

  group('CustomFilledButton', () {
    testWidgets('calls onPressed and plays the press animation', (
      tester,
    ) async {
      var pressed = 0;
      await tester.pumpWidget(
        host(CustomFilledButton(title: 'Go', onPressed: () => pressed++)),
      );
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
      expect(pressed, 1);
    });

    testWidgets('does nothing while disabled', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        host(
          CustomFilledButton(
            title: 'Go',
            isDisabled: true,
            onPressed: () => pressed++,
          ),
        ),
      );
      await tester.tap(find.text('Go'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(pressed, 0);
    });

    testWidgets('shows a spinner while loading', (tester) async {
      await tester.pumpWidget(
        host(const CustomFilledButton(title: 'Go', isLoading: true)),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  testWidgets('CustomTextButton calls onPressed', (tester) async {
    var pressed = 0;
    await tester.pumpWidget(
      host(CustomTextButton(title: 'More', onPressed: () => pressed++)),
    );
    await tester.tap(find.text('More'));
    expect(pressed, 1);
  });

  group('CustomFormField', () {
    testWidgets('shows its title and hint', (tester) async {
      await tester.pumpWidget(
        host(const CustomFormField(title: 'Email', hintText: 'you@mail.com')),
      );
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('you@mail.com'), findsOneWidget);
    });

    testWidgets('password field toggles visibility', (tester) async {
      await tester.pumpWidget(
        host(
          const CustomFormField(
            title: 'Password',
            hintText: '',
            isPasswordField: true,
          ),
        ),
      );
      bool obscured() =>
          tester.widget<EditableText>(find.byType(EditableText)).obscureText;

      expect(obscured(), isTrue);
      await tester.enterText(find.byType(TextFormField), 'secret');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();
      expect(obscured(), isFalse);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });
  });

  group('CustomErrorItem', () {
    test('friendlyMessage maps network errors and falls back', () {
      final context = _FakeContext();
      expect(
        CustomErrorItem.friendlyMessage(context, null),
        'Something went wrong',
      );
      expect(
        CustomErrorItem.friendlyMessage(context, ''),
        'Something went wrong',
      );
      expect(
        CustomErrorItem.friendlyMessage(
          context,
          'SocketException: Failed host lookup',
        ),
        'No internet connection',
      );
      expect(
        CustomErrorItem.friendlyMessage(context, 'Bad request'),
        'Something went wrong',
      );
    });

    testWidgets('shows default title and message without retry', (
      tester,
    ) async {
      await tester.pumpWidget(host(const CustomErrorItem()));
      expect(find.text('Oops!'), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });
  });

  group('CustomLoadingAnimation', () {
    testWidgets(
      'starts and stops with isLoading and blocks back while loading',
      (tester) async {
        Widget build(bool loading) => host(
          CustomLoadingAnimation(
            isLoading: loading,
            child: const Text('content'),
          ),
        );

        await tester.pumpWidget(build(false));
        expect(find.byType(ModalBarrier), findsWidgets);
        expect(find.byType(CustomPaint), findsWidgets);
        final barriersIdle = find.byType(ModalBarrier).evaluate().length;

        await tester.pumpWidget(build(true));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(ModalBarrier).evaluate().length, barriersIdle + 1);
        expect(tester.widget<PopScope>(find.byType(PopScope)).canPop, isFalse);
        expect(
          tester.widget<ModalBarrier>(find.byType(ModalBarrier).last).color,
          blackColor.withValues(alpha: 0.6),
        );

        await tester.pumpWidget(build(true));
        await tester.pumpWidget(build(false));
        await tester.pumpAndSettle();
        expect(find.text('content'), findsOneWidget);
        expect(tester.widget<PopScope>(find.byType(PopScope)).canPop, isTrue);
      },
    );

    test('LoadingPainter repaints only when the color changes', () {
      const animation = AlwaysStoppedAnimation(0.0);
      final painter = LoadingPainter(animation, Colors.blue);
      expect(
        painter.shouldRepaint(LoadingPainter(animation, Colors.blue)),
        isFalse,
      );
      expect(
        painter.shouldRepaint(LoadingPainter(animation, Colors.red)),
        isTrue,
      );
    });
  });

  testWidgets('PosterCard without onTap still renders the placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(host(const PosterCard(posterPath: null)));
    expect(find.byIcon(Icons.movie), findsOneWidget);
  });
}

class _FakeContext extends Fake implements BuildContext {}
