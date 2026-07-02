import 'package:sqflite/sqflite.dart';
import 'package:teacher_notebook/database/database_helper.dart';
import 'package:teacher_notebook/models/lesson_model.dart';

class LessonRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertLesson(Lesson lesson) async {
    final db = await _dbHelper.database;
    return await db.insert(
      DatabaseHelper.tableLessons,
      lesson.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Lesson>> getLessonsByGroup(int groupId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableLessons,
      where: 'groupId = ?',
      whereArgs: [groupId],
      orderBy: 'date DESC',
    );
    return List.generate(
      maps.length,
      (i) => Lesson.fromMap(maps[i]),
    );
  }

  Future<List<Lesson>> getTodayLessons() async {
    final db = await _dbHelper.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final maps = await db.query(
      DatabaseHelper.tableLessons,
      where: 'date >= ? AND date < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'date ASC',
    );
    return List.generate(
      maps.length,
      (i) => Lesson.fromMap(maps[i]),
    );
  }

  Future<Lesson?> getLessonById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableLessons,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Lesson.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateLesson(Lesson lesson) async {
    final db = await _dbHelper.database;
    return await db.update(
      DatabaseHelper.tableLessons,
      lesson.toMap(),
      where: 'id = ?',
      whereArgs: [lesson.id],
    );
  }

  Future<int> deleteLesson(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DatabaseHelper.tableLessons,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
