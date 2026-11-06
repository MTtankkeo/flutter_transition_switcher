import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Defines the sizing policies for [TransitionStack].
enum TransitionStackSize {
  /// Uses the last child size.
  lastChild,

  /// Uses the minimum width and height across all children.
  min,

  /// Uses the maximum width and height across all children.
  max,
}

/// Overlays children using the selected sizing policy and alignment.
class TransitionStack extends MultiChildRenderObjectWidget {
  const TransitionStack({
    super.key,
    this.sizing = .lastChild,
    required this.alignment,
    required super.children,
  });

  /// The policy used to determine the stack size.
  final TransitionStackSize sizing;

  /// The alignment of children within the stack.
  final AlignmentGeometry alignment;

  @override
  RenderTransitionStack createRenderObject(BuildContext context) {
    return RenderTransitionStack(
      alignment: alignment.resolve(Directionality.maybeOf(context)),
      sizing: sizing,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderTransitionStack renderObject) {
    renderObject
      ..alignment = alignment.resolve(Directionality.maybeOf(context))
      ..sizing = sizing;
  }
}

/// Lays out overlapping children with independently selected container sizing.
class RenderTransitionStack extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _TransitionStackParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _TransitionStackParentData> {
  RenderTransitionStack({
    required this._alignment,
    required this._sizing,
  });

  Alignment _alignment;
  Alignment get alignment => _alignment;
  set alignment(Alignment value) {
    if (_alignment != value) {
      _alignment = value;
      markNeedsLayout();
    }
  }

  TransitionStackSize _sizing;
  TransitionStackSize get sizing => _sizing;
  set sizing(TransitionStackSize value) {
    if (_sizing != value) {
      _sizing = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _TransitionStackParentData) {
      child.parentData = _TransitionStackParentData();
    }
  }

  @override
  void performLayout() {
    if (firstChild == null) {
      size = constraints.smallest;
      return;
    }

    final childConstraints = constraints.loosen();
    Size? contentSize;

    // Measure every child without forcing it to match the selected size.
    for (RenderBox? child = firstChild; child != null; child = childAfter(child)) {
      child.layout(childConstraints, parentUsesSize: true);
      final previousSize = contentSize;

      if (previousSize == null) {
        contentSize = child.size;
      } else if (sizing == .min) {
        contentSize = Size(
          min(previousSize.width, child.size.width),
          min(previousSize.height, child.size.height),
        );
      } else if (sizing == .max) {
        contentSize = Size(
          max(previousSize.width, child.size.width),
          max(previousSize.height, child.size.height),
        );
      }
    }

    final selectedSize = switch (sizing) {
      .lastChild => lastChild!.size,
      .min || .max => contentSize!,
    };

    size = constraints.constrain(selectedSize);

    // Align children within the selected size, allowing larger children to overflow.
    for (RenderBox? child = firstChild; child != null; child = childAfter(child)) {
      final parentData = child.parentData! as _TransitionStackParentData;

      parentData.offset = alignment.alongOffset(
        Offset(
          size.width - child.size.width,
          size.height - child.size.height,
        ),
      );
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

/// Parent data for children of [RenderTransitionStack].
class _TransitionStackParentData extends ContainerBoxParentData<RenderBox> {}
