import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(child: MyApp()),
  );
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

// enum of cities
enum City {
  stockholm,
  paris,
  tokyo,
}

// function to create weather for city
typedef WeatherEmoji = String;
Future<WeatherEmoji> getWeather(City city) {
  return Future.delayed(
      const Duration(seconds: 1),
      () => {
            City.stockholm: '☀️',
            City.paris: '☁️',
            City.tokyo: '🥶',
          }[city]!);
}

// provider that keeps hold of state (state provider)
// Ui writes and reads to or from this provider
final currentCityProvider = StateProvider<City?>(
  (ref) => null,
);

const unknownWeatherEmoji = '🤷‍♂️';

// Ui reads from this provider
final weatherProvider = FutureProvider<WeatherEmoji>((ref) {
  final city = ref.watch(currentCityProvider);
  if (city != null) {
    return getWeather(city);
  } else {
    return unknownWeatherEmoji;
  }
});

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeather = ref.watch(weatherProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
      ),
      body: Column(
        children: [
          currentWeather.when(
            data: (data) => Text(
              data,
              style: const TextStyle(fontSize: 40),
            ),
            error: (_, __) => const Text('Error 😭'),
            loading: () => const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: City.values.length,
                  itemBuilder: (context, index) {
                    final city = City.values[index];
                    final isSelected = city == ref.watch(currentCityProvider);
                    return ListTile(
                      title: Text(city.toString()),
                      trailing: isSelected ? const Icon(Icons.check) : null,
                      onTap: () =>
                          ref.read(currentCityProvider.notifier).state = city,
                    );
                  }))
        ],
      ),
    );
  }
}
