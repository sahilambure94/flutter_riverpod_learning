import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'dart:collection';

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

@immutable
class Person {
  // immutable class
  final String name;
  final int age;
  final String uuid;

  Person({required this.name, required this.age, String? uuid})
      : uuid = uuid ?? const Uuid().v4();

  Person updated([String? name, int? age]) => Person(
        name: name ?? this.name,
        age: age ?? this.age,
        uuid: uuid,
      );

  String get displayName => '$name ($age years old)';

  @override
  bool operator ==(covariant Person other) => uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;

  @override
  String toString() => 'Person(name: $name, age: $age, uuid: $uuid)';
}

class DataModel extends ChangeNotifier {
  final List<Person> _people = [];
  int get count => _people.length;
  UnmodifiableListView<Person> get people => UnmodifiableListView(_people);
  void add(Person person) {
    _people.add(person);
    notifyListeners();
  }

  void remove(Person person) {
    _people.remove(person);
    notifyListeners();
  }

  void update(Person updatedPerson) {
    final index = _people.indexOf(updatedPerson);
    final previousInfo = _people[index];
    if (previousInfo.name != updatedPerson.name ||
        previousInfo.age != updatedPerson.age) {
      _people[index] =
          previousInfo.updated(updatedPerson.name, updatedPerson.age);
      notifyListeners();
    }
  }
}

final peopleProvider = ChangeNotifierProvider<DataModel>(
  (_) => DataModel(),
);

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('HomePage'),
        ),
        body: Consumer(
          builder: (context, ref, child) {
            final dataModel = ref.watch(peopleProvider);
            return ListView.builder(
              itemCount: dataModel.count,
              itemBuilder: (context, index) {
                final person = dataModel.people[index];
                return ListTile(
                  title: GestureDetector(
                    child: Text(person.displayName),
                    onTap: () async {
                      final updatedPerson = await createOrUpdatePersonDialog(
                        context,
                        person,
                      );
                      if (updatedPerson != null) {
                        dataModel.update(updatedPerson);
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final person = await createOrUpdatePersonDialog(context);
            if (person != null) {
              final dataModel = ref.read(peopleProvider);
              dataModel.add(person);
            }
          },
          child: const Icon(Icons.add),
        ));
  }
}

final nameController = TextEditingController();
final ageController = TextEditingController();

Future<Person?> createOrUpdatePersonDialog(
  BuildContext context, [
  Person? existingPerson,
]) {
  String? name = existingPerson?.name;
  int? age = existingPerson?.age;

  nameController.text = name ?? '';
  ageController.text = age?.toString() ?? '';

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add Person'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Enter name here...',
              ),
              onChanged: (value) => name = value,
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(
                labelText: 'Enter age here...',
              ),
              onChanged: (value) => age = int.tryParse(value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (name != null && age != null) {
                if (existingPerson != null) {
                  final newPerson = existingPerson.updated(
                    name,
                    age,
                  );
                  Navigator.of(context).pop(
                    newPerson,
                  );
                } else {
                  // no existing person, create new one
                  Navigator.of(context).pop(Person(
                    name: name!,
                    age: age!,
                  ));
                }
              } else {
                // no name or age or both, dismiss dialog
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
