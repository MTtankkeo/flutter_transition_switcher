import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transition_switcher/transition_switcher.dart';

/// Builds a [TransitionStack] with the given sizing, alignment, and children.
Widget _buildWidget({
  TransitionStackSize sizing = .lastChild,
  AlignmentGeometry alignment = .topLeft,
  TextDirection textDirection = .ltr,
  required List<Widget> children,
}) {
  return Directionality(
    textDirection: textDirection,
    child: Center(
      child: TransitionStack(
        sizing: sizing,
        alignment: alignment,
        children: children,
      ),
    ),
  );
}

void main() {
  final smallKey = const ValueKey('small');
  final largeKey = const ValueKey('large');
  const smallSize = Size(100, 50);
  const largeSize = Size(200, 150);

  final small = find.byKey(smallKey);
  final large = find.byKey(largeKey);
  final stack = find.byType(TransitionStack);

  Widget buildSmall() => SizedBox.fromSize(key: smallKey, size: smallSize);
  Widget buildLarge() => SizedBox.fromSize(key: largeKey, size: largeSize);

  for (final (sizing, expectedSize) in [
    (TransitionStackSize.lastChild, smallSize),
    (TransitionStackSize.min, smallSize),
    (TransitionStackSize.max, largeSize),
  ]) {
    testWidgets('$sizing selects the expected width and height', (tester) async {
      await tester.pumpWidget(
        _buildWidget(
          sizing: sizing,
          children: [
            buildLarge(),
            buildSmall(),
          ],
        ),
      );

      // Use the fixed child sizes to verify the selected sizing policy.
      expect(tester.getSize(stack), expectedSize);
    });
  }

  testWidgets('Changing alignment repositions children within the stack', (tester) async {
    for (final (alignment, expectedOffset) in [
      (Alignment.topLeft, Offset.zero),
      (Alignment.topRight, const Offset(100, 0)),
      (Alignment.center, const Offset(50, 50)),
      (Alignment.bottomLeft, const Offset(0, 100)),
      (Alignment.bottomRight, const Offset(100, 100)),
    ]) {
      await tester.pumpWidget(
        _buildWidget(
          alignment: alignment,
          children: [
            buildSmall(),
            buildLarge(),
          ],
        ),
      );

      // Check the smaller child position relative to the stack.
      expect(tester.getTopLeft(small) - tester.getTopLeft(stack), expectedOffset);
      expect(tester.getSize(stack), largeSize);
    }
  });

  testWidgets('Directional alignment follows text direction', (tester) async {
    for (final (direction, expectedOffset) in [
      (TextDirection.ltr, const Offset(0, 50)),
      (TextDirection.rtl, const Offset(100, 50)),
    ]) {
      await tester.pumpWidget(
        _buildWidget(
          alignment: .centerStart,
          textDirection: direction,
          children: [
            buildSmall(),
            buildLarge(),
          ],
        ),
      );

      // Start resolves to the left in LTR and the right in RTL.
      expect(tester.getTopLeft(small) - tester.getTopLeft(stack), expectedOffset);
    }
  });

  testWidgets('A larger outgoing child keeps its size outside the smaller stack', (tester) async {
    await tester.pumpWidget(
      _buildWidget(
        alignment: .center,
        children: [
          buildLarge(),
          buildSmall(),
        ],
      ),
    );

    // The previous child remains full-sized and centered around the current child.
    expect(tester.getSize(stack), smallSize);
    expect(tester.getSize(large), largeSize);
    expect(tester.getTopLeft(large) - tester.getTopLeft(stack), const Offset(-50, -50));
    expect(tester.getTopLeft(small), tester.getTopLeft(stack));
  });
}
