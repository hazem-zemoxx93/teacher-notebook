import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String _databaseName = 'teacher_notebook.db';
  static const int _databaseVersion = 1;

  static const String tableGroups = 'groups';
  static const String tableStudents = 'students';
  static const String tableLessons = 'lessons';
  static const String tableAttendance = 'attendance';
  static const String tablePayments = 'payments';

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableGroups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        subject TEXT NOT NULL,
        schedule TEXT NOT NULL,
        monthlyFee REAL NOT NULL,
        notes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableStudents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        parentPhone TEXT,
        groupId INTEGER NOT NULL,
        monthlyFeeOverride REAL,
        notes TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY(groupId) REFERENCES $tableGroups(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableLessons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        groupId INTEGER NOT NULL,
        date TEXT NOT NULL,
        topic TEXT NOT NULL,
        notes TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY(groupId) REFERENCES $tableGroups(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableAttendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER NOT NULL,
        lessonId INTEGER NOT NULL,
        isPresent INTEGER NOT NULL,
        recordedAt TEXT NOT NULL,
        FOREIGN KEY(studentId) REFERENCES $tableStudents(id) ON DELETE CASCADE,
        FOREIGN KEY(lessonId) REFERENCES $tableLessons(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablePayments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER NOT NULL,
        groupId INTEGER NOT NULL,
        amount REAL NOT NULL,
        dueDate TEXT NOT NULL,
        paidDate TEXT,
        isPaid INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY(studentId) REFERENCES $tableStudents(id) ON DELETE CASCADE,
        FOREIGN KEY(groupId) REFERENCES $tableGroups(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }

  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete(tableAttendance);
    await db.delete(tablePayments);
    await db.delete(tableLessons);
    await db.delete(tableStudents);
    await db.delete(tableGroups);
  }
}