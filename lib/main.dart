import 'dart:convert';
import 'package:flutter/material.dart';

import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.greenAccent,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email == 'admin' && password == '123') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NextPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants Billing'),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[200],
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: _login,
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NextPage extends StatefulWidget {
  const NextPage({Key? key}) : super(key: key);

  @override
  _NextPageState createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  List<Map<String, String>> peopleList = [];
  int _idCounter = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    String? data = LocalStorage.getString('peopleList');
    if (data != null) {
      setState(() {
        peopleList = List<Map<String, String>>.from(jsonDecode(data));
        _idCounter = peopleList.length; // Continue from the last ID
      });
    }
  }

  void _saveData(Map<String, String> newPerson) {
    newPerson['id'] = (_idCounter++).toString(); // Auto-increment ID
    peopleList.add(newPerson);
    LocalStorage.setString('peopleList', jsonEncode(peopleList));
    setState(() {});
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final positionController = TextEditingController();
    final companyController = TextEditingController();
    File? selectedImage;

    Future<void> _pickImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          selectedImage = File(pickedFile.path);
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Person'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                TextFormField(
                  controller: positionController,
                  decoration: const InputDecoration(
                    labelText: 'Position',
                  ),
                ),
                TextFormField(
                  controller: companyController,
                  decoration: const InputDecoration(
                    labelText: 'Company',
                  ),
                ),
                const SizedBox(height: 16.0),
                selectedImage != null
                    ? Image.file(selectedImage!)
                    : const Text('No image selected'),
                TextButton(
                  onPressed: _pickImage,
                  child: const Text('Select Image'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Map<String, String> newPerson = {
                  'name': nameController.text,
                  'position': positionController.text,
                  'company': companyController.text,
                  'imagePath': selectedImage?.path ?? '',
                };
                _saveData(newPerson);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('People-Chart'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'People-Chart',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showAddDialog(context);
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity, // Ensures table takes up full width
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Position')),
                  DataColumn(label: Text('Company')),
                  DataColumn(label: Text('Image')),
                ],
                rows: peopleList.map((person) {
                  return DataRow(
                    cells: [
                      DataCell(Text(person['id'] ?? '')),
                      DataCell(Text(person['name'] ?? '')),
                      DataCell(Text(person['position'] ?? '')),
                      DataCell(Text(person['company'] ?? '')),
                      DataCell(person['imagePath'] != null &&
                              person['imagePath']!.isNotEmpty
                          ? Image.file(
                              File(person['imagePath']!),
                              width: 50,
                              height: 50,
                            )
                          : const Text('No Image')),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImagePicker() {}
}

class ImageSource {
  static var gallery;
}

class LocalStorage {
  static final Map<String, String> _storage = {};

  static String? getString(String key) {
    return _storage[key];
  }

  static void setString(String key, String value) {
    _storage[key] = value;
  }
}

final localStorage = LocalStorage();
