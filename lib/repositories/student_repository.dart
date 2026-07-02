import 'package:sqflite/sqflite.dart';
import 'package:teacher_notebook/database/database_helper.dart';
import 'package:teacher_notebook/models/student_model.dart';

class StudentRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertStudent(Student student) async {
    final db = await _dbHelper.database;
    return await db.insert(
      DatabaseHelper.tableStudents,
      student.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Student>> getAllStudents() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableStudents,
      where: 'isActive = 1',
    );
    return List.generate(
      maps.length,
      (i) => Student.fromMap(maps[i]),
    );
  }

  Future<List<Student>> getStudentsByGroup(int groupId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableStudents,
      where: 'groupId = ? AND isActive = 1',
      whereArgs: [groupId],
    );
    return List.generate(
      maps.length,
      (i) => Student.fromMap(maps[i]),
    );
  }

  Future<Student?> getStudentById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableStudents,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Student.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Student>> searchStudents(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableStudents,
      where: 'isActive = 1 AND (fullName LIKE ? OR phoneNumber LIKE ? OR parentPhone LIKE ?)',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return List.generate(
      maps.length,
      (i) => Student.fromMap(maps[i]),
    );
  }

  Future<int> updateStudent(Student student) async {
    final db = await _dbHelper.database;
    return await db.update(
      DatabaseHelper.tableStudents,
      student.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deactivateStudent(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      DatabaseHelper.tableStudents,
      {'isActive': 0, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getTotalStudentCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableStudents} WHERE isActive = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
