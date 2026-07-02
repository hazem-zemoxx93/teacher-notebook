import 'package:sqflite/sqflite.dart';
import 'package:teacher_notebook/database/database_helper.dart';
import 'package:teacher_notebook/models/group_model.dart';

class GroupRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertGroup(Group group) async {
    final db = await _dbHelper.database;
    return await db.insert(
      DatabaseHelper.tableGroups,
      group.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Group>> getAllGroups() async {
    final db = await _dbHelper.database;
    final maps = await db.query(DatabaseHelper.tableGroups);
    return List.generate(
      maps.length,
      (i) => Group.fromMap(maps[i]),
    );
  }

  Future<Group?> getGroupById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableGroups,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Group.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateGroup(Group group) async {
    final db = await _dbHelper.database;
    return await db.update(
      DatabaseHelper.tableGroups,
      group.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [group.id],
    );
  }

  Future<int> deleteGroup(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DatabaseHelper.tableGroups,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getGroupStudentCount(int groupId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableStudents} WHERE groupId = ? AND isActive = 1',
      [groupId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
