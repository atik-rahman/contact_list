import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const ContactListApp());

class ContactListApp extends StatelessWidget {
  const ContactListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ContactListPage(),
    );
  }
}

class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  ContactListPageState createState() => ContactListPageState();
}

class ContactListPageState extends State<ContactListPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _contacts = [];

  @override
  void initState() {
    super.initState();
    _refreshContacts();
  }

  void _refreshContacts() async {
    final data = await _databaseHelper.queryAllContacts();
    setState(() {
      _contacts = data;
    });
  }

  void _addContact() async {
    final name = _nameController.text;
    final mobile = _mobileController.text;

    if (name.isNotEmpty && mobile.isNotEmpty) {
      await _databaseHelper.insertContact({'name': name, 'mobile': mobile});
      _nameController.clear();
      _mobileController.clear();
      _refreshContacts();
    }
  }

  void _deleteContact(int id) async {
    await _databaseHelper.deleteContact(id);
    _refreshContacts();
  }

  void _confirmDeleteContact(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: const Text('Are you sure you want to delete this contact?'),
        actions: [
          TextButton(
            onPressed: () {
              _deleteContact(id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _makeCall(String number) async {
    final url = 'tel:$number';
    if (await canLaunchUrl(url as Uri)) {
      await launchUrl(url as Uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact List', textAlign: TextAlign.center),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _mobileController,
              decoration: const InputDecoration(labelText: 'Mobile Number'),
              keyboardType: TextInputType.phone,
            ),
            ElevatedButton(
              onPressed: _addContact,
              child: const Text('Add to the contact list'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _contacts.length,
                itemBuilder: (context, index) {
                  final contact = _contacts[index];
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(contact['name']),
                    subtitle: Text(contact['mobile']),
                    trailing: IconButton(
                      icon: const Icon(Icons.phone),
                      onPressed: () => _makeCall(contact['mobile']),
                    ),
                    onLongPress: () => _confirmDeleteContact(contact['id']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}