import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'academic_management.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE courses (
        courseId INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        duration INTEGER NOT NULL,
        coordinator TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');
    //Tabela de estudantes
    await db.execute('''
    CREATE TABLE students (
      studentId INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT NOT NULL,
      ra TEXT NOT NULL,
      courseId INTEGER,
      FOREIGN KEY (courseId) REFERENCES courses (courseId) ON DELETE SET NULL
    )
  ''');

    // Tabela de Professores
    await db.execute('''
    CREATE TABLE teachers (
      teacherId INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT NOT NULL,
      subject TEXT NOT NULL
    )
  ''');
  }
}
