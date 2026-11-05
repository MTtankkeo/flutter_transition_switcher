import 'package:flutter/material.dart';
import 'package:transitions/transitions.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Example(),
          ),
        ),
      ),
    );
  }
}

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  var count = 1;

  @override
  Widget build(BuildContext context) {
    return TransitionSwitcher(
      switchInDuration: const .new(milliseconds: 500),
      switchInCurve: Curves.ease, // Defaults to Curves.linear.
      transitionBuilder: FadeThroughTransition.builder,
      child: TextButton(
        key: ValueKey(count),
        onPressed: () {
          setState(() => count += 1);
        },
        child: Text('$count'),
      ),
    );
  }
}
