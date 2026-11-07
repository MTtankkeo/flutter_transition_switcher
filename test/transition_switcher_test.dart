import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transition_switcher/transition_switcher.dart';

import 'test.dart';

void main() {
  testWidgets('Matching type and key update the child without losing state', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        TextButton(
          key: const ValueKey('A'),
          onPressed: () {},
          child: const Text('Before'),
        ),
      ),
    );

    final state = tester.state(find.byType(TextButton));

    // Update the content while keeping the same widget type and key.
    await tester.pumpWidget(
      buildTestApp(
        TextButton(
          key: const ValueKey('A'),
          onPressed: () {},
          child: const Text('After'),
        ),
      ),
    );

    // Verify that the existing state is reused and the content is updated.
    expect(tester.state(find.byType(TextButton)), same(state));
    expect(find.text('Before'), findsNothing);
    expect(find.text('After'), findsOneWidget);
    expect(transitionFinder, findsOneWidget);

    // Verify that no entrance or exit animation was started.
    final transition = tester.widget<CrossFadeTransition>(transitionFinder);
    expect(transition.primaryAnimation.value, 1);
    expect(transition.secondaryAnimation.value, 0);
  });

  testWidgets('A different key keeps the outgoing child until its exit completes', (tester) async {
    await tester.pumpWidget(buildTestApp(const Text('A', key: ValueKey('A'))));
    await tester.pumpWidget(buildTestApp(const Text('B', key: ValueKey('B'))));

    // Both children remain mounted while the transition is active.
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);

    // Advance halfway and check both animation values.
    await tester.pump(const Duration(milliseconds: 100));

    final transitions = tester.widgetList<CrossFadeTransition>(transitionFinder).toList();

    expect(transitions.first.secondaryAnimation.value, 0.5);
    expect(transitions.last.primaryAnimation.value, 0.5);

    // Advance past the exit duration and verify that only B remains.
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('A'), findsNothing);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('Rapid A to B to A switches clean up each outgoing entry independently', (tester) async {
    await tester.pumpWidget(buildTestApp(const Text('A', key: ValueKey('A'))));
    await tester.pumpWidget(buildTestApp(const Text('B', key: ValueKey('B'))));
    await tester.pump(const Duration(milliseconds: 50));

    // Switch back to A before the first transition completes.
    await tester.pumpWidget(buildTestApp(const Text('A', key: ValueKey('A'))));

    // The original A and the new A must remain separate entries.
    expect(find.text('A'), findsNWidgets(2));
    expect(find.text('B'), findsOneWidget);

    // The original A finishes exiting, while B is still leaving.
    await tester.pump(const Duration(milliseconds: 160));
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);

    // B finishes exiting, leaving only the newest A.
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsNothing);
    expect(find.byType(CrossFadeTransition), findsOneWidget);
  });

  testWidgets('Entrance and exit durations run independently', (tester) async {
    // Use a longer entrance duration than exit duration.
    Widget build(String label) {
      return buildTestApp(
        Text(label, key: ValueKey(label)),
        switchInDuration: const .new(milliseconds: 400),
        switchOutDuration: const .new(milliseconds: 100),
      );
    }

    // Replace A with B and advance past the shorter exit duration.
    await tester.pumpWidget(build('A'));
    await tester.pumpWidget(build('B'));
    await tester.pump(const Duration(milliseconds: 120));

    // A has been removed, but B is only 30% through its entrance.
    expect(find.text('A'), findsNothing);

    final transition = tester.widget<CrossFadeTransition>(transitionFinder);
    expect(transition.primaryAnimation.value, closeTo(0.3, 0.001));

    // Advance past the entrance duration and verify that B is fully shown.
    await tester.pump(const Duration(milliseconds: 300));
    expect(transition.primaryAnimation.value, 1);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('Removing the switcher during transitions disposes active tickers', (tester) async {
    // Start several overlapping transitions so multiple controllers are active.
    await tester.pumpWidget(buildTestApp(const Text('A', key: ValueKey('A'))));
    await tester.pumpWidget(buildTestApp(const Text('B', key: ValueKey('B'))));
    await tester.pump(const Duration(milliseconds: 50));

    await tester.pumpWidget(buildTestApp(const Text('C', key: ValueKey('C'))));
    expect(find.byType(CrossFadeTransition), findsNWidgets(3));

    // Remove the switcher before the transitions finish.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    // Verify that disposal raises no errors and leaves no scheduled tickers.
    expect(tester.takeException(), isNull);
    expect(tester.binding.transientCallbackCount, 0);
  });
}
