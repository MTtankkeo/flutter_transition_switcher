import 'package:flutter/widgets.dart';
import 'package:transition_switcher/src/sliver_transform.dart';
import 'package:transition_switcher/transition_switcher.dart';

/// Combines the entrance and exit scales into a single animation.
class _ScaleFadeAnimation extends CompoundAnimation<double> {
  _ScaleFadeAnimation({required super.first, required super.next});

  @override
  double get value => first.value * next.value;
}

/// Converts a scale factor into a paint transformation matrix.
class _ScaleTransform extends Animatable<Matrix4> {
  const _ScaleTransform();

  @override
  Matrix4 transform(double value) => .diagonal3Values(value, value, 1);
}

/// Scales and fades a child in and out over separate transition intervals.
class ScaleFadeTransition extends StatelessWidget {
  const ScaleFadeTransition({
    super.key,
    this.switchInScale = 0.9,
    this.switchOutScale = 1.1,
    this.switchInBegin = 0.5,
    this.switchInEnd = 1.0,
    this.switchOutBegin = 0.0,
    this.switchOutEnd = 0.5,
    required this.primaryAnimation,
    required this.secondaryAnimation,
    required this.child,
  }) : assert(
         switchInScale != 1 || switchOutScale != 1,
         'Use FadeThroughTransition when both scale values are 1.',
       ),
       assert(switchInBegin >= 0 && switchInBegin <= 1),
       assert(switchOutBegin >= 0 && switchOutBegin <= 1),
       assert(switchInEnd >= switchInBegin && switchInEnd <= 1),
       assert(switchOutEnd >= switchOutBegin && switchOutEnd <= 1);

  /// The scale at the beginning of the entrance transition, ending at one.
  final double switchInScale;

  /// The scale at the end of the exit transition, starting at one.
  final double switchOutScale;

  /// The progress at which the entrance fade begins.
  final double switchInBegin;

  /// The progress at which the entrance fade ends.
  final double switchInEnd;

  /// The progress at which the exit fade begins.
  final double switchOutBegin;

  /// The progress at which the exit fade ends.
  final double switchOutEnd;

  /// The animation that increases opacity as the child enters.
  final Animation<double> primaryAnimation;

  /// The animation that decreases opacity as the child leaves.
  final Animation<double> secondaryAnimation;

  /// The child to fade in and out.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final switchIn = primaryAnimation.drive(
      CurveTween(curve: Interval(switchInBegin, switchInEnd)),
    );

    final switchOut = secondaryAnimation.drive(
      CurveTween(curve: Interval(switchOutBegin, switchOutEnd)),
    );

    final animation = _ScaleFadeAnimation(
      first: switchIn.drive(Tween(begin: switchInScale, end: 1)),
      next: switchOut.drive(Tween(begin: 1, end: switchOutScale)),
    );

    return ScaleTransition(
      scale: animation,
      child: CrossFadeTransition(
        primaryAnimation: switchIn,
        secondaryAnimation: switchOut,
        child: child,
      ),
    );
  }

  /// Builds a scale-fade transition for use with
  /// [TransitionSwitcher.transitionBuilder].
  static Widget builder(
    Widget child,
    Animation<double> primaryAnimation,
    Animation<double> secondaryAnimation,
  ) {
    return ScaleFadeTransition(
      primaryAnimation: primaryAnimation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

/// Scales and fades a sliver in and out over separate transition intervals.
class SliverScaleFadeTransition extends StatelessWidget {
  const SliverScaleFadeTransition({
    super.key,
    this.switchInScale = 0.9,
    this.switchOutScale = 1.1,
    this.switchInBegin = 0.5,
    this.switchInEnd = 1.0,
    this.switchOutBegin = 0.0,
    this.switchOutEnd = 0.5,
    required this.primaryAnimation,
    required this.secondaryAnimation,
    required this.sliver,
  }) : assert(
         switchInScale != 1 || switchOutScale != 1,
         'Use SliverFadeThroughTransition when both scale values are 1.',
       ),
       assert(switchInBegin >= 0 && switchInBegin <= 1),
       assert(switchOutBegin >= 0 && switchOutBegin <= 1),
       assert(switchInEnd >= switchInBegin && switchInEnd <= 1),
       assert(switchOutEnd >= switchOutBegin && switchOutEnd <= 1);

  /// The scale at the beginning of the entrance transition, ending at one.
  final double switchInScale;

  /// The scale at the end of the exit transition, starting at one.
  final double switchOutScale;

  /// The progress at which the entrance fade begins.
  final double switchInBegin;

  /// The progress at which the entrance fade ends.
  final double switchInEnd;

  /// The progress at which the exit fade begins.
  final double switchOutBegin;

  /// The progress at which the exit fade ends.
  final double switchOutEnd;

  /// The animation that increases opacity as the sliver enters.
  final Animation<double> primaryAnimation;

  /// The animation that decreases opacity as the sliver leaves.
  final Animation<double> secondaryAnimation;

  /// The sliver to fade in and out.
  final Widget sliver;

  @override
  Widget build(BuildContext context) {
    final switchIn = primaryAnimation.drive(
      CurveTween(curve: Interval(switchInBegin, switchInEnd)),
    );

    final switchOut = secondaryAnimation.drive(
      CurveTween(curve: Interval(switchOutBegin, switchOutEnd)),
    );

    final animation = _ScaleFadeAnimation(
      first: switchIn.drive(Tween(begin: switchInScale, end: 1)),
      next: switchOut.drive(Tween(begin: 1, end: switchOutScale)),
    );

    return SliverTransform(
      transform: animation.drive(const _ScaleTransform()),
      sliver: SliverCrossFadeTransition(
        primaryAnimation: switchIn,
        secondaryAnimation: switchOut,
        sliver: sliver,
      ),
    );
  }

  /// Builds a sliver scale-fade transition for use with
  /// [TransitionSwitcher.transitionBuilder].
  static Widget builder(
    Widget sliver,
    Animation<double> primaryAnimation,
    Animation<double> secondaryAnimation,
  ) {
    return SliverScaleFadeTransition(
      primaryAnimation: primaryAnimation,
      secondaryAnimation: secondaryAnimation,
      sliver: sliver,
    );
  }
}
