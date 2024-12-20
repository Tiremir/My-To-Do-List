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

  List<Item> items = [];

  void _addItem() {
    setState(() {
      items.add(Item(title: 'Item ${Item.counter + 1}', isChecked: false));
    });
  }

  void _removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

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
        child: ReorderableListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Dismissible(
              key: Key(items[index].title),
              onDismissed: (direction) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${items[index].title} удален')),
                );
                _removeItem(index);
              },
              child: CheckboxListTile(
                key: Key(items[index].title),
                title: Text(items[index].title),
                value: items[index].isChecked,
                onChanged: (value) {
                  setState(() {
                    items[index].isChecked = value!;
                  });
                }
              ),
            );
          },
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final Item item = items.removeAt(oldIndex);
              items.insert(newIndex, item);
            });
          }
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: const Icon(Icons.add)
      ),
    );
  }
}

class Item {
  Item({required this.title, required this.isChecked}) {
    counter++;
  }

  static int counter = 0;
  String title;
  bool isChecked;
}