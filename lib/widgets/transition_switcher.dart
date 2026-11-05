import 'package:flutter/widgets.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:transition_switcher/src/transition_entry.dart';

/// Signature for a function that builds a transition for
/// a child of [TransitionSwitcher].
typedef TransitionSwitcherTransitionBuilder =
    Widget Function(
      Widget child,
      Animation<double> primaryAnimation,
      Animation<double> secondaryAnimation,
    );

/// Signature for builders used to generate custom layouts for
/// [TransitionSwitcher].
typedef TransitionSwitcherLayoutBuilder = Widget Function(List<Widget> entries);

/// Switches between keyed children using separate enter and exit animations.
class TransitionSwitcher extends StatefulWidget {
  const TransitionSwitcher({
    super.key,
    required this.switchInDuration,
    this.switchOutDuration,
    this.switchInCurve = Curves.linear,
    this.switchOutCurve,
    this.layoutBuilder = defaultLayoutBuilder,
    required this.transitionBuilder,
    required this.child,
  });

  /// The duration of the entrance animation.
  final Duration switchInDuration;

  /// The duration of the exit animation.
  ///
  /// Defaults to [switchInDuration] when null.
  final Duration? switchOutDuration;

  /// The curve applied to the entrance animation.
  final Curve switchInCurve;

  /// The curve applied to the exit animation.
  ///
  /// Defaults to [switchInCurve] when null.
  final Curve? switchOutCurve;

  /// The builder for the layout containing the outgoing
  /// and current children.
  final TransitionSwitcherLayoutBuilder layoutBuilder;

  /// The builder for each child transition using
  /// its primary and secondary animations.
  final TransitionSwitcherTransitionBuilder transitionBuilder;

  /// The child currently displayed by the switcher.
  ///
  /// A non-null key is required to identify the child.
  /// Changing its type or key starts a new transition.
  final Widget child;

  /// Places outgoing children below the current child.
  static Widget defaultLayoutBuilder(List<Widget> entries) {
    return Stack(alignment: .center, children: entries);
  }

  @override
  State<TransitionSwitcher> createState() => _TransitionSwitcherState();
}

class _TransitionSwitcherState extends State<TransitionSwitcher> with TickerProviderStateMixin {
  /// The outgoing entries followed by the current entry.
  final List<TransitionEntry> entries = [];

  /// The current entry, which is the last item in [entries].
  TransitionEntry get switchIn => entries.last;

  /// Creates an entry for the current child, optionally animating its entrance.
  TransitionEntry createEntry({required bool animate}) {
    assert(
      widget.child.key != null,
      'Each child must have a non-null key so TransitionSwitcher can identify '
      'which child is entering or leaving during a transition.',
    );

    return .new(
      vsync: this,
      switchInDuration: widget.switchInDuration,
      switchOutDuration: widget.switchOutDuration ?? widget.switchInDuration,
      switchInCurve: widget.switchInCurve,
      switchOutCurve: widget.switchOutCurve ?? widget.switchInCurve,
      child: widget.child,
      animate: animate,
      onDispose: (entry) {
        setState(() => entries.remove(entry));
      },
    );
  }

  @override
  void initState() {
    super.initState();

    // Add the initial child without an entrance animation.
    entries.add(createEntry(animate: false));
  }

  @override
  void didUpdateWidget(covariant TransitionSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);

    assert(
      widget.child.key != null,
      'Each child must have a non-null key so TransitionSwitcher can identify '
      'which child is entering or leaving during a transition.',
    );

    // Update the current child without a transition if its type and key match.
    if (Widget.canUpdate(switchIn.child, widget.child)) {
      switchIn.child = widget.child;
      return;
    }

    // Add the incoming child before starting the current child exit animation.
    final outgoing = switchIn;
    entries.add(createEntry(animate: true));

    outgoing.secondaryController.forward();
  }

  @override
  void dispose() {
    for (final entry in entries) {
      entry.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.layoutBuilder([
      for (final entry in entries)
        KeyedSubtree(
          key: entry.key,
          child: widget.transitionBuilder(
            entry.child,
            entry.primaryAnimation,
            entry.secondaryAnimation,
          ),
        ),
    ]);
  }
}

/// Switches between keyed slivers using separate enter and exit animations.
class SliverTransitionSwitcher extends TransitionSwitcher {
  const SliverTransitionSwitcher({
    super.key,
    required super.switchInDuration,
    super.switchOutDuration,
    super.switchInCurve = Curves.linear,
    super.switchOutCurve,
    super.layoutBuilder = defaultLayoutBuilder,
    required super.transitionBuilder,
    required Widget sliver,
  }) : super(child: sliver);

  /// Places outgoing children below the current sliver.
  static Widget defaultLayoutBuilder(List<Widget> entries) {
    return SliverStack(children: entries);
  }
}
