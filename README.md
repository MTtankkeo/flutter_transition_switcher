# Introduction

A Flutter package for customizable transition animations between widgets and slivers.

It supports separate entrance and exit durations and curves, custom layouts, and sliver transitions.

```dart
import 'package:transition_switcher/transition_switcher.dart';

TransitionSwitcher(
  switchInDuration: const .new(milliseconds: 500),
  switchInCurve: Curves.ease, // Defaults to Curves.linear.
  transitionBuilder: FadeThroughTransition.builder,
  child: Text(
    '$count',
    key: ValueKey(count),
  ),
);
```

Each child must have a non-null key. Changing its type or key starts a new transition; matching children update without a transition.

## Supported Transitions

| Class Name | Description | Sliver |
| ---- | ----------- | ------ |
| CrossFadeTransition | Fades the outgoing child out while fading the incoming child in. | 🟢 |
| FadeThroughTransition | Fades the outgoing child out before fading the incoming child in. | 🟢 |
