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

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

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
              title: Text('Задача 1'),
            ),
            ListTile(
              title: Text('Задача 1'),
            ),
            ListTile(
              title: Text('Задача 1'),
            ),
          ],
        )
      ),
      body: Center(
        child: ListView(
          children: const [
            ListTile(
              title: Text('Задача 1'),
            ),
            ListTile(
              title: Text('Задача 1'),
            ),
            ListTile(
              title: Text('Задача 1'),
            ),
            ListTile(
              title: Text('Задача 1'),
            ),
            ListTile(
              title: Text('Задача 1'),
            ),
            ListTile(
              title: Text('Задача 1'),
            ),
            ListTile(
              title: Text('Задача 1'),
            ),
            ListTile(
              title: Text('Задача 1'),
            ),
          ],
        )
      ),
    );
  }
}
