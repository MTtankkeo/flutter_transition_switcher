import 'package:flutter/widgets.dart';
import 'package:transition_switcher/src/sliver_transform.dart';
import 'package:transition_switcher/transition_switcher.dart';

/// Combines entrance and exit slide offsets into a single animation.
class _SlideFadeAnimation extends CompoundAnimation<Offset> {
  _SlideFadeAnimation({
    required super.first,
    required super.next,
  });

  @override
  Offset get value => first.value + next.value;
}

/// Combines entrance and exit translation matrices into a single animation.
class _SlideMatrixAnimation extends CompoundAnimation<Matrix4> {
  _SlideMatrixAnimation({
    required super.first,
    required super.next,
  });

  @override
  Matrix4 get value => first.value * next.value;
}

/// Slides and fades a child in and out over separate transition intervals.
class SlideFadeTransition extends StatelessWidget {
  const SlideFadeTransition({
    super.key,
    required this.switchInOffset,
    required this.switchOutOffset,
    this.switchInBegin = 0.5,
    this.switchInEnd = 1.0,
    this.switchOutBegin = 0.0,
    this.switchOutEnd = 0.5,
    required this.primaryAnimation,
    required this.secondaryAnimation,
    required this.child,
  }) : assert(
         switchInOffset != .zero || switchOutOffset != .zero,
         'Use FadeThroughTransition when both translation values are zero.',
       ),
       assert(switchInBegin >= 0 && switchInBegin <= 1),
       assert(switchOutBegin >= 0 && switchOutBegin <= 1),
       assert(switchInEnd >= switchInBegin && switchInEnd <= 1),
       assert(switchOutEnd >= switchOutBegin && switchOutEnd <= 1);

  /// The entrance offset as a fraction of the child size, ending at zero.
  final Offset switchInOffset;

  /// The exit offset as a fraction of the child size, starting at zero.
  final Offset switchOutOffset;

  /// The progress at which the entrance slide and fade begin.
  final double switchInBegin;

  /// The progress at which the entrance slide and fade end.
  final double switchInEnd;

  /// The progress at which the exit slide and fade begin.
  final double switchOutBegin;

  /// The progress at which the exit slide and fade end.
  final double switchOutEnd;

  /// The animation that drives the entrance slide and fade.
  final Animation<double> primaryAnimation;

  /// The animation that drives the exit slide and fade.
  final Animation<double> secondaryAnimation;

  /// The child to slide and fade in and out.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final switchIn = primaryAnimation.drive(
      CurveTween(curve: Interval(switchInBegin, switchInEnd)),
    );

    final switchOut = secondaryAnimation.drive(
      CurveTween(curve: Interval(switchOutBegin, switchOutEnd)),
    );

    final animation = _SlideFadeAnimation(
      first: switchIn.drive(Tween(begin: switchInOffset, end: .zero)),
      next: switchOut.drive(Tween(begin: .zero, end: switchOutOffset)),
    );

    return SlideTransition(
      position: animation,
      child: CrossFadeTransition(
        primaryAnimation: switchIn,
        secondaryAnimation: switchOut,
        child: child,
      ),
    );
  }

  /// Creates a slide-fade transition in the given direction.
  ///
  /// The factor is a fraction of the child size along the selected axis.
  /// When [reverseExit] is true, the child exits toward the side it entered from.
  factory SlideFadeTransition.directional({
    Key? key,
    required AxisDirection direction,
    bool reverseExit = false,
    double factor = 0.1,
    double switchInBegin = 0.5,
    double switchInEnd = 1.0,
    double switchOutBegin = 0.0,
    double switchOutEnd = 0.5,
    required Animation<double> primaryAnimation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    final offset = switch (direction) {
      .up => Offset(0, -factor),
      .down => Offset(0, factor),
      .left => Offset(-factor, 0),
      .right => Offset(factor, 0),
    };

    return .new(
      key: key,
      switchInOffset: -offset,
      switchOutOffset: reverseExit ? -offset : offset,
      switchInBegin: switchInBegin,
      switchInEnd: switchInEnd,
      switchOutBegin: switchOutBegin,
      switchOutEnd: switchOutEnd,
      primaryAnimation: primaryAnimation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

/// Slides and fades a sliver in and out over separate transition intervals.
class SliverSlideFadeTransition extends StatelessWidget {
  const SliverSlideFadeTransition({
    super.key,
    required this.switchInOffset,
    required this.switchOutOffset,
    this.switchInBegin = 0.5,
    this.switchInEnd = 1.0,
    this.switchOutBegin = 0.0,
    this.switchOutEnd = 0.5,
    required this.primaryAnimation,
    required this.secondaryAnimation,
    required this.sliver,
  }) : assert(
         switchInOffset != .zero || switchOutOffset != .zero,
         'Use SliverFadeThroughTransition when both translation values are zero.',
       ),
       assert(switchInBegin >= 0 && switchInBegin <= 1),
       assert(switchOutBegin >= 0 && switchOutBegin <= 1),
       assert(switchInEnd >= switchInBegin && switchInEnd <= 1),
       assert(switchOutEnd >= switchOutBegin && switchOutEnd <= 1);

  /// The entrance offset as a fraction of the sliver painted size, ending at zero.
  final Offset switchInOffset;

  /// The exit offset as a fraction of the sliver painted size, starting at zero.
  final Offset switchOutOffset;

  /// The progress at which the entrance slide and fade begin.
  final double switchInBegin;

  /// The progress at which the entrance slide and fade end.
  final double switchInEnd;

  /// The progress at which the exit slide and fade begin.
  final double switchOutBegin;

  /// The progress at which the exit slide and fade end.
  final double switchOutEnd;

  /// The animation that drives the entrance slide and fade.
  final Animation<double> primaryAnimation;

  /// The animation that drives the exit slide and fade.
  final Animation<double> secondaryAnimation;

  /// The sliver to slide and fade in and out.
  final Widget sliver;

  @override
  Widget build(BuildContext context) {
    final switchIn = primaryAnimation.drive(
      CurveTween(curve: Interval(switchInBegin, switchInEnd)),
    );

    final switchOut = secondaryAnimation.drive(
      CurveTween(curve: Interval(switchOutBegin, switchOutEnd)),
    );

    final animation = _SlideMatrixAnimation(
      // Move from the entrance offset to the original position.
      first: switchIn.drive(
        Matrix4Tween(
          begin: .translationValues(
            switchInOffset.dx,
            switchInOffset.dy,
            0.0,
          ),
          end: .identity(),
        ),
      ),

      // Move from the original position to the exit offset.
      next: switchOut.drive(
        Matrix4Tween(
          begin: .identity(),
          end: .translationValues(
            switchOutOffset.dx,
            switchOutOffset.dy,
            0.0,
          ),
        ),
      ),
    );

    return SliverTransform(
      transform: animation,
      sliver: SliverCrossFadeTransition(
        primaryAnimation: switchIn,
        secondaryAnimation: switchOut,
        sliver: sliver,
      ),
    );
  }

  /// Creates a sliver slide-fade transition in the given direction.
  ///
  /// The factor is a fraction of the sliver painted size along the selected axis.
  /// When [reverseExit] is true, the sliver exits toward the side it entered from.
  factory SliverSlideFadeTransition.directional({
    Key? key,
    required AxisDirection direction,
    bool reverseExit = false,
    double factor = 0.1,
    double switchInBegin = 0.5,
    double switchInEnd = 1.0,
    double switchOutBegin = 0.0,
    double switchOutEnd = 0.5,
    required Animation<double> primaryAnimation,
    required Animation<double> secondaryAnimation,
    required Widget sliver,
  }) {
    final offset = switch (direction) {
      .up => Offset(0, -factor),
      .down => Offset(0, factor),
      .left => Offset(-factor, 0),
      .right => Offset(factor, 0),
    };

    return .new(
      key: key,
      switchInOffset: -offset,
      switchOutOffset: reverseExit ? -offset : offset,
      switchInBegin: switchInBegin,
      switchInEnd: switchInEnd,
      switchOutBegin: switchOutBegin,
      switchOutEnd: switchOutEnd,
      primaryAnimation: primaryAnimation,
      secondaryAnimation: secondaryAnimation,
      sliver: sliver,
    );
  }
}
