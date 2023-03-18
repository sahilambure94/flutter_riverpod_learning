import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
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

const names = [
  "Excited",
  "Anxious",
  "Overweight",
  "Demonic",
  "Jumpy",
  "Misunderstood",
  "Squashed",
  "Gargantuan",
  "Broad",
  "Crooked",
  "Curved",
  "Deep",
];

final tickerProvider = StreamProvider(
  (ref) => Stream.periodic(
    const Duration(
      seconds: 1,
    ),
    (i) => i + 1,
  ),
);

// if tickerProvider = 1 then names[1] is the output

final namesProvider =
    StreamProvider((ref) => ref.watch(tickerProvider.stream).map(
          (count) => names.getRange(0, count),
        ));

// final namesProvider = FutureProvider((ref) async {
//   final count = await ref.watch(tickerProvider.future);
//   return names.getRange(0, count);
// });

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final names = ref.watch(namesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stream Provider'),
      ),
      body: names.when(
        data: (names) {
          return ListView.builder(
            itemCount: names.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(names.elementAt(index)),
              );
            },
          );
        },
        error: (error, stack) => const Center(
          child: Text('Reached the end of the list'),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
