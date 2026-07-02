import 'package:sqflite/sqflite.dart';
import 'package:teacher_notebook/database/database_helper.dart';
import 'package:teacher_notebook/models/attendance_model.dart';

class AttendanceRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertAttendance(Attendance attendance) async {
    final db = await _dbHelper.database;
    return await db.insert(
      DatabaseHelper.tableAttendance,
      attendance.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Attendance>> getAttendanceByLesson(int lessonId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableAttendance,
      where: 'lessonId = ?',
      whereArgs: [lessonId],
    );
    return List.generate(
      maps.length,
      (i) => Attendance.fromMap(maps[i]),
    );
  }

  Future<List<Attendance>> getStudentAttendance(int studentId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableAttendance,
      where: 'studentId = ?',
      whereArgs: [studentId],
      orderBy: 'recordedAt DESC',
    );
    return List.generate(
      maps.length,
      (i) => Attendance.fromMap(maps[i]),
    );
  }

  Future<Attendance?> getAttendanceRecord(int studentId, int lessonId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableAttendance,
      where: 'studentId = ? AND lessonId = ?',
      whereArgs: [studentId, lessonId],
    );
    if (maps.isNotEmpty) {
      return Attendance.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateAttendance(Attendance attendance) async {
    final db = await _dbHelper.database;
    return await db.update(
      DatabaseHelper.tableAttendance,
      attendance.toMap(),
      where: 'id = ?',
      whereArgs: [attendance.id],
    );
  }

  Future<int> deleteAttendance(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DatabaseHelper.tableAttendance,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getStudentAttendancePercentage(int studentId) async {
    final db = await _dbHelper.database;
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableAttendance} WHERE studentId = ?',
      [studentId],
    );
    final total = Sqflite.firstIntValue(totalResult) ?? 0;
    
    if (total == 0) return 0.0;
    
    final presentResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableAttendance} WHERE studentId = ? AND isPresent = 1',
      [studentId],
    );
    final present = Sqflite.firstIntValue(presentResult) ?? 0;
    
    return (present / total) * 100;
  }
}
