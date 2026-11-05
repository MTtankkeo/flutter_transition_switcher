import 'package:flutter/widgets.dart';
import 'package:transitions/transitions.dart';

/// Combines entrance opacity with inverse exit opacity into a single animation.
class _CrossFadeAnimation extends CompoundAnimation<double> {
  _CrossFadeAnimation({
    required super.first,
    required super.next,
  });

  @override
  double get value => first.value * (1 - next.value);
}

/// Fades a child in with the primary animation
/// and out with the secondary animation.
class CrossFadeTransition extends StatelessWidget {
  const CrossFadeTransition({
    super.key,
    required this.primaryAnimation,
    required this.secondaryAnimation,
    required this.child,
  });

  /// The animation that increases opacity as the child enters.
  final Animation<double> primaryAnimation;

  /// The animation that decreases opacity as the child leaves.
  final Animation<double> secondaryAnimation;

  /// The child to fade in and out.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _CrossFadeAnimation(
        first: primaryAnimation,
        next: secondaryAnimation,
      ),
      child: child,
    );
  }

  /// Builds a cross-fade transition for use with
  /// [TransitionSwitcher.transitionBuilder].
  static Widget builder(
    Widget child,
    Animation<double> primaryAnimation,
    Animation<double> secondaryAnimation,
  ) {
    return CrossFadeTransition(
      primaryAnimation: primaryAnimation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

/// Fades a sliver in with the primary animation
/// and out with the secondary animation.
class SliverCrossFadeTransition extends StatelessWidget {
  const SliverCrossFadeTransition({
    super.key,
    required this.primaryAnimation,
    required this.secondaryAnimation,
    required this.sliver,
  });

  /// The animation that increases opacity as the child enters.
  final Animation<double> primaryAnimation;

  /// The animation that decreases opacity as the child leaves.
  final Animation<double> secondaryAnimation;

  /// The sliver to fade in and out.
  final Widget sliver;

  @override
  Widget build(BuildContext context) {
    return SliverFadeTransition(
      opacity: _CrossFadeAnimation(
        first: primaryAnimation,
        next: secondaryAnimation,
      ),
      sliver: sliver,
    );
  }

  /// Builds a sliver cross-fade transition for use with
  /// [TransitionSwitcher.transitionBuilder].
  static Widget builder(
    Widget sliver,
    Animation<double> primaryAnimation,
    Animation<double> secondaryAnimation,
  ) {
    return SliverCrossFadeTransition(
      primaryAnimation: primaryAnimation,
      secondaryAnimation: secondaryAnimation,
      sliver: sliver,
    );
  }
}
