import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transition_switcher/transition_switcher.dart';

/// Finds the cross-fade transitions in the widget tree.
final transitionFinder = find.byType(CrossFadeTransition);

/// Builds a test app containing a [TransitionSwitcher] with the given child.
Widget buildTestApp(
  Widget child, {
  Duration switchInDuration = const .new(milliseconds: 200),
  Duration? switchOutDuration,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: TransitionSwitcher(
          switchInDuration: switchInDuration,
          switchOutDuration: switchOutDuration,
          transitionBuilder: CrossFadeTransition.builder,
          child: child,
        ),
      ),
    ),
  );
}
