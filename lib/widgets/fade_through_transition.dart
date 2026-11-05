import 'package:flutter/widgets.dart';
import 'package:transitions/transitions.dart';

/// Fades a child in and out over separate intervals of its transition animations.
class FadeThroughTransition extends StatelessWidget {
  const FadeThroughTransition({
    super.key,
    this.switchInBegin = 0.5,
    this.switchInEnd = 1.0,
    this.switchOutBegin = 0.0,
    this.switchOutEnd = 0.5,
    required this.primaryAnimation,
    required this.secondaryAnimation,
    required this.child,
  }) : assert(switchInBegin >= 0 && switchInBegin <= 1),
       assert(switchOutBegin >= 0 && switchOutBegin <= 1),
       assert(switchInEnd >= switchInBegin && switchInEnd <= 1),
       assert(switchOutEnd >= switchOutBegin && switchOutEnd <= 1);

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
    return CrossFadeTransition(
      primaryAnimation: primaryAnimation.drive(
        CurveTween(curve: Interval(switchInBegin, switchInEnd)),
      ),
      secondaryAnimation: secondaryAnimation.drive(
        CurveTween(curve: Interval(switchOutBegin, switchOutEnd)),
      ),
      child: child,
    );
  }

  /// Builds a fade-through transition for use with
  /// [TransitionSwitcher.transitionBuilder].
  static Widget builder(
    Widget child,
    Animation<double> primaryAnimation,
    Animation<double> secondaryAnimation,
  ) {
    return FadeThroughTransition(
      primaryAnimation: primaryAnimation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

/// Fades a sliver in and out over separate intervals of its transition animations.
class SliverFadeThroughTransition extends StatelessWidget {
  const SliverFadeThroughTransition({
    super.key,
    this.switchInBegin = 0.5,
    this.switchInEnd = 1.0,
    this.switchOutBegin = 0.0,
    this.switchOutEnd = 0.5,
    required this.primaryAnimation,
    required this.secondaryAnimation,
    required this.sliver,
  }) : assert(switchInBegin >= 0 && switchInBegin <= 1),
       assert(switchOutBegin >= 0 && switchOutBegin <= 1),
       assert(switchInEnd >= switchInBegin && switchInEnd <= 1),
       assert(switchOutEnd >= switchOutBegin && switchOutEnd <= 1);

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
    return SliverCrossFadeTransition(
      primaryAnimation: primaryAnimation.drive(
        CurveTween(curve: Interval(switchInBegin, switchInEnd)),
      ),
      secondaryAnimation: secondaryAnimation.drive(
        CurveTween(curve: Interval(switchOutBegin, switchOutEnd)),
      ),
      sliver: sliver,
    );
  }

  /// Builds a sliver fade-through transition for use with
  /// [TransitionSwitcher.transitionBuilder].
  static Widget builder(
    Widget sliver,
    Animation<double> primaryAnimation,
    Animation<double> secondaryAnimation,
  ) {
    return SliverFadeThroughTransition(
      primaryAnimation: primaryAnimation,
      secondaryAnimation: secondaryAnimation,
      sliver: sliver,
    );
  }
}
