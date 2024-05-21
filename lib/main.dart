import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SafeArea(child: MyHomePage()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> users = [];
  final TextEditingController _nameController = TextEditingController();
  @override
  void initState() {
    super.initState();
    initDatabaseAndFetchUsers();
  }

  Future<void> initDatabaseAndFetchUsers() async {
    final sql.Database database = await sql.openDatabase(
      'user.db',
      version: 1,
      onCreate: (sql.Database db, int version) async {
        await db.execute(
          'CREATE TABLE user(id INTEGER PRIMARY KEY, name TEXT)',
        );
      },
    );
    final List<Map<String, dynamic>> fetchedUsers =
        await database.query('user');
    setState(() {
      users = fetchedUsers;
    });
    await database.close();
  }

  Future<void> insertUser(String name) async {
    final sql.Database database = await sql.openDatabase(
      'user.db',
      version: 1,
    );
    await database.rawInsert(
      'INSERT INTO user(name) VALUES(?)',
      [name],
    );
    await database.close();
    await initDatabaseAndFetchUsers();
  }

  Future<void> editUser(int id, String newName) async {
    final sql.Database database = await sql.openDatabase(
      'user.db',
      version: 1,
    );
    await database.rawUpdate(
      'UPDATE user SET name = ? WHERE id = ?',
      [newName, id],
    );
    await database.close();
    await initDatabaseAndFetchUsers();
  }

  Future<void> deleteUser(int id) async {
    final sql.Database database = await sql.openDatabase(
      'user.db',
      version: 1,
    );
    await database.rawDelete(
      'DELETE FROM user WHERE id = ?',
      [id],
    );
    await database.close();
    await initDatabaseAndFetchUsers();
  }

  void _showEditDialog(int userId, String currentName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newName = currentName;
        return AlertDialog(
          title: Text('Edit User'),
          content: TextField(
            onChanged: (value) {
              newName = value;
            },
            controller: TextEditingController(text: currentName),
            decoration: InputDecoration(labelText: 'New Name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                editUser(userId, newName);
                Navigator.of(context).pop();
              },  
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Input nama',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID: ${users[index]['id']}'),
                        Text('Name: ${users[index]['name']}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _showEditDialog(
                                users[index]['id'], users[index]['name']);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            deleteUser(users[index]['id']);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add User'),
          content: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Enter Name',
                ),
              ),
            ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                insertUser(_nameController.text);
                _nameController.clear();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
      }, child: Text('+'),),
    );
  }
}
