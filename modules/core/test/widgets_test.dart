import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

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

    testWidgets('holding the button plays the press animation', (tester) async {
      await tester.pumpWidget(
        host(CustomFilledButton(title: 'Go', onPressed: () {})),
      );
      double scale() => tester
          .widget<Transform>(
            find
                .descendant(
                  of: find.byType(CustomFilledButton),
                  matching: find.byType(Transform),
                )
                .first,
          )
          .transform
          .entry(0, 0);

      expect(scale(), 1.0);
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Go')),
      );
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 60));
      expect(scale(), isNot(1.0));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(scale(), closeTo(1.0, 0.001));
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

    testWidgets('shows a retry button that calls onRetry', (tester) async {
      var retries = 0;
      await tester.pumpWidget(
        host(CustomErrorItem(message: 'Boom', onRetry: () => retries++)),
      );
      expect(find.text('Boom'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(retries, 1);
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

  group('shared poster and snack widgets', () {
    testWidgets('PosterSection shows the title and reports taps', (
      tester,
    ) async {
      var seeMore = 0;
      int? tapped;
      await tester.pumpWidget(
        host(
          PosterSection(
            title: 'Popular',
            posterPaths: const [null, null],
            onSeeMore: () => seeMore++,
            onTap: (i) => tapped = i,
          ),
        ),
      );
      expect(find.text('Popular'), findsOneWidget);
      await tester.tap(find.text('See More'));
      await tester.tap(find.byType(PosterCard).last);
      expect((seeMore, tapped), (1, 1));
    });

    testWidgets('PosterTile shows title and subtitle and reports taps', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        host(
          PosterTile(
            posterPath: null,
            title: 'Dark',
            subtitle: '★ 8.4',
            onTap: () => taps++,
          ),
        ),
      );
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('★ 8.4'), findsOneWidget);
      await tester.tap(find.text('Dark'));
      expect(taps, 1);
    });

    testWidgets('WatchlistIconButton switches icon, color and tooltip', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(WatchlistIconButton(isAdded: false, onPressed: () {})),
      );
      expect(find.byTooltip('Add to Watchlist'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      await tester.pumpWidget(
        host(WatchlistIconButton(isAdded: true, onPressed: () {})),
      );
      expect(find.byTooltip('Remove from Watchlist'), findsOneWidget);
      expect(
        tester.widget<IconButton>(find.byType(IconButton)).color,
        Colors.red,
      );
    });

    testWidgets('showAppSnack shows a success and an error snack', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Column(
                children: [
                  TextButton(
                    onPressed: () => showAppSnack(context, 'Saved'),
                    child: const Text('ok'),
                  ),
                  TextButton(
                    onPressed: () =>
                        showAppSnack(context, 'Broken', isError: true),
                    child: const Text('fail'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('ok'));
      await tester.pump();
      expect(find.text('Success'), findsOneWidget);
      expect(find.text('Saved'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      await tester.tap(find.text('fail'));
      await tester.pump();
      expect(find.text('Failed'), findsOneWidget);
      expect(find.text('Broken'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });
  });

  testWidgets('PosterCard falls back to the icon when the image fails', (
    tester,
  ) async {
    await tester.pumpWidget(host(const PosterCard(posterPath: '/broken.jpg')));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.movie), findsOneWidget);
  });

  testWidgets('PosterCard without onTap still renders the placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(host(const PosterCard(posterPath: null)));
    expect(find.byIcon(Icons.movie), findsOneWidget);
  });
}

class _FakeContext extends Fake implements BuildContext {}
