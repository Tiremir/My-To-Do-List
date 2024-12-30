import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() async {
  //SharedPreferences prefs = await SharedPreferences.getInstance();
  //prefs.clear();
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

  void _addItem(String title) {
    setState(() {
      items.add(Item(title: title, isChecked: false));
    });
    _saveData();
  }

  void _removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
    _saveData();
  }

  void _showAddItemDialog() {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            String? errorMessage;
            if(controller.text.isEmpty) {
              errorMessage = 'Пожалуйста, введите значение';
            } else if(items.any((item) => item.title == controller.text)) {
              errorMessage = 'Это значение уже существует';
            } else {
              errorMessage = null;
            }

            return AlertDialog(
              title: const Text('Добавить объект'),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(hintText: 'Введите название', errorText: errorMessage),
                autofocus: true,
                onChanged: (value) => setState(() {}),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if(controller.text.isNotEmpty && items.every((item) => item.title != controller.text)) {
                      _addItem(controller.text);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Добавить'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Отмена'),
                ),
              ],
            );
          },
        );
      }
    );
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('items');
    if (jsonString != null) {
      List<dynamic> jsonList = json.decode(jsonString);
      items = jsonList.map((json) => Item.fromJson(json)).toList();
      setState(() {});
    }
  }

  void _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = json.encode(items.map((item) => item.toJson()).toList());
    await prefs.setString('items', jsonString);
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
                  _saveData();
                }
              ),
            );
          },
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex--;
              }
              final Item item = items.removeAt(oldIndex);
              items.insert(newIndex, item);
            });
          }
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add)
      ),
    );
  }
}

class Item {
  Item({required this.title, required this.isChecked});

  String title;
  bool isChecked;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isChecked': isChecked,
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      title: json['title'],
      isChecked: json['isChecked'],
    );
  }
}