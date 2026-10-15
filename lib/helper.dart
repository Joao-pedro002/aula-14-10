import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String caminho = join(await getDatabasesPath(), 'pets.db');
    return await openDatabase(
      caminho,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pets (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT,
            idade INTEGER
          )
        ''');
      },
    );
  }

  static Future<int> inserirPet(Map<String, dynamic> pet) async {
    Database db = await database;
    return await db.insert('pets', pet);
  }

  static Future<List<Map<String, dynamic>>> listarPets() async {
    Database db = await database;
    return await db.query('pets');
  }

  static Future<int> atualizarPet(int id, String nome, int idade) async {
    Database db = await database;
    return await db.update(
      'pets',
      {'nome': nome, 'idade': idade},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> apagarPet(int id) async {
    Database db = await database;
    return await db.delete(
      'pets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
