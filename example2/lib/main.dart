import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

// Infix Operator
// Any value that extends number will work on number? optional values
extension OptionalInfixAddition<T extends num> on T? {
  T? operator +(T? other) {
    final shadow = this; // left hand side value
    if (shadow != null) {
      return shadow + (other ?? 0) as T;
    } else {
      return null;
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

// State Notifier: notify you of state changes

class CountPlus1 extends StateNotifier<int?> {
  CountPlus1() : super(null);
  void increment() => state = state == null ? 1 : state + 1;
}

final counterProvider =
    StateNotifierProvider<CountPlus1, int?>((ref) => CountPlus1());

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // // watch the counterProvider (i am using watch here because i want to rebuild the widget when the value changes)
    // final counter = ref.watch(counterProvider);
    // this final counter value waster our resource as it rebuilds scaffold every time the value changes instead using consumerWidget
    return Scaffold(
      appBar: AppBar(
        // Consumer only rebuilds title when the value changes saving resources
        title: Consumer(
          builder: (context, ref, child) {
            final count = ref.watch(counterProvider);
            final text = count == null ? 'Press the Button' : '$count';
            return Text(text);
          },
        ),
      ),
      body: Column(
        // button in middle of screen
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextButton(
            // acessing to provider
            onPressed: () {
              ref.read(counterProvider.notifier).increment();
              // ref read gets the current value or snapshot of the provider
            },
            child: const Text('Increment Counter'),
          ),
        ],
      ),
    );
  }
}
