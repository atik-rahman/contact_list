import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper{
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async{
    if(_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async{
    String path = join(await getDatabasesPath(), 'contact_list.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version){
        return db.execute(
          "CREATE TABLE contact_list(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, mobile TEXT)",
        );
      }
    );
  }

  Future<int> insertContact(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('contact_list', row);
  }

  Future<List<Map<String, dynamic>>> queryAllContacts() async {
    Database db = await database;
    return await db.query('contact_list');
  }

  Future<int> deleteContact(int id) async {
    Database db = await database;
    return await db.delete('contact_list', where: 'id = ?', whereArgs: [id]);
  }
}