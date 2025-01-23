import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() async {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  bool? _isDarkTheme;

  void _toggleTheme() async {
    setState(() {
      _isDarkTheme = !_isDarkTheme!;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('Is Dark Theme', _isDarkTheme!);
  }

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  void loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState( () {
      _isDarkTheme = prefs.getBool('Is Dark Theme') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(_isDarkTheme == null) {
      return Container();
    }
    return SafeArea(
      child: MaterialApp(
        title: 'My To-Do List',
        theme: ThemeData(colorSchemeSeed: Colors.amber, brightness: _isDarkTheme! ? Brightness.dark : Brightness.light),
        home: MyHomePage(toggleTheme: _toggleTheme),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.toggleTheme});

  final VoidCallback toggleTheme;

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

  void _renameItem(int index, String newTitle) {
    setState(() {
      items[index].title = newTitle;
    });
    _saveData();
  }

  void _toggleSelection(int index) {
    setState(() {
      items[index].isSelected = !items[index].isSelected;
    });
  }

  void _deleteSelectedItems() {
    setState(() {
      items.removeWhere((item) => item.isSelected);
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
                onChanged: (value) => setState(() {})
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

  void _showRenameItemDialog(int index) {
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
              title: const Text('Переименование объекта'),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(hintText: 'Введите название', errorText: errorMessage),
                autofocus: true,
                onChanged: (value) => setState(() {})
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if(controller.text.isNotEmpty && items.every((item) => item.title != controller.text)) {
                      _renameItem(index, controller.text);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Переименовать'),
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
        actions: [
          if(items.any((item) => item.isSelected)) IconButton(
            onPressed: items.every((item) => item.isSelected) ?
              () => setState(() {for (var item in items) {item.isSelected = false;}})
              : () => setState(() {for (var item in items) {item.isSelected = true;}}),
            icon: const Icon(Icons.checklist)
          ),
          if(items.any((item) => item.isSelected)) IconButton(
            onPressed: _deleteSelectedItems,
            icon: const Icon(Icons.delete)
          ),
          IconButton(
            onPressed: widget.toggleTheme,
            icon: const Icon(Icons.brightness_4)
          )
        ],
      ),
      body: Center(
        child: ReorderableListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              key: Key(items[index].title),
              onTap: items.every((item) => !item.isSelected) ?
                () => _showRenameItemDialog(index)
                : () => _toggleSelection(index),
              onLongPress: items.every((item) => !item.isSelected) ?
                () => _toggleSelection(index)
                : null,
              child: Container(
                color: items[index].isSelected ? Theme.of(context).focusColor : null,
                child: ListTile(
                  key: Key(items[index].title),
                  title: Text(items[index].title),
                  leading: Checkbox(
                    value: items[index].isChecked,
                    onChanged: (value) {
                      setState(() {
                        items[index].isChecked = value!;
                      });
                      _saveData();
                    }
                  ),
                  onTap: items.every((item) => !item.isSelected) ?
                    () => _showRenameItemDialog(index)
                    : () => _toggleSelection(index),
                  onLongPress: items.every((item) => !item.isSelected) ?
                    () => _toggleSelection(index)
                    : null,
                ),
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
  bool isSelected = false;

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