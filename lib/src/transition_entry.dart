import 'package:flutter/widgets.dart';

/// Manages a child transition animations and their controllers.
///
/// The primary animation runs when the child enters,
/// and the secondary animation runs when it leaves.
class TransitionEntry {
  TransitionEntry({
    required TickerProvider vsync,
    required Duration switchInDuration,
    required Duration switchOutDuration,
    required Curve switchInCurve,
    required Curve switchOutCurve,
    required this.child,
    required bool animate,
    required ValueChanged<TransitionEntry> onDispose,
  }) {
    primaryController = AnimationController(
      vsync: vsync,
      duration: switchInDuration,
      value: animate ? 0 : 1,
    );

    secondaryController = AnimationController(
      vsync: vsync,
      duration: switchOutDuration,
    );

    primaryAnimation = primaryController.drive(
      CurveTween(curve: switchInCurve),
    );

    secondaryAnimation = secondaryController.drive(
      CurveTween(curve: switchOutCurve),
    );

    // Dispose the entry and notify its owner when the exit animation completes.
    secondaryController.addStatusListener((status) {
      if (status == .completed) {
        onDispose(this..dispose());
      }
    });

    if (animate) {
      primaryController.forward();
    }
  }

  /// The unique key that preserves this entry identity in the layout.
  final Key key = UniqueKey();

  /// The child associated with this entry.
  Widget child;

  /// The controller that drives the entrance animation.
  late final AnimationController primaryController;

  /// The controller that drives the exit animation.
  late final AnimationController secondaryController;

  /// The entrance animation with the switch-in curve applied.
  late final Animation<double> primaryAnimation;

  /// The exit animation with the switch-out curve applied.
  late final Animation<double> secondaryAnimation;

  /// Disposes the controllers used by the entrance and exit animations.
  void dispose() {
    primaryController.dispose();
    secondaryController.dispose();
  }
}
