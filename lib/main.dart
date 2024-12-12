import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        title: 'My To-Do List',
        theme: ThemeData(
          colorSchemeSeed: Colors.amber
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final List<String> _items = ['Apple', 'Ball', 'Cat', 'Dog', 'Elephant'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My To-Do List'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: Drawer(
        child: ListView(
          children: const [
            ListTile(
              title: Text('Элемент'),
            ),
            ListTile(
              title: Text('Элемент'),
            ),
            ListTile(
              title: Text('Элемент'),
            ),
          ],
        )
      ),
      body: Center(
        child: ReorderableListView(
          children: _items.asMap().entries.map((entry) {
            return ListTile(
              key: Key(entry.key.toString()),
              title: Text(entry.value),
            );
          }).toList(),
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final String item = _items.removeAt(oldIndex);
              _items.insert(newIndex, item);
            });
          }
        )
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => setState(() {_items.add('Задача');}), child: const Icon(Icons.add)),
    );
  }
}
