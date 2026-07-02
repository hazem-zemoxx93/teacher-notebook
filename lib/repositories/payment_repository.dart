import 'package:sqflite/sqflite.dart';
import 'package:teacher_notebook/database/database_helper.dart';
import 'package:teacher_notebook/models/payment_model.dart';

class PaymentRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertPayment(Payment payment) async {
    final db = await _dbHelper.database;
    return await db.insert(
      DatabaseHelper.tablePayments,
      payment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Payment>> getAllPayments() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tablePayments,
      orderBy: 'dueDate ASC',
    );
    return List.generate(
      maps.length,
      (i) => Payment.fromMap(maps[i]),
    );
  }

  Future<List<Payment>> getStudentPayments(int studentId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tablePayments,
      where: 'studentId = ?',
      whereArgs: [studentId],
      orderBy: 'dueDate ASC',
    );
    return List.generate(
      maps.length,
      (i) => Payment.fromMap(maps[i]),
    );
  }

  Future<List<Payment>> getUnpaidPayments() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tablePayments,
      where: 'isPaid = 0',
      orderBy: 'dueDate ASC',
    );
    return List.generate(
      maps.length,
      (i) => Payment.fromMap(maps[i]),
    );
  }

  Future<Payment?> getPaymentById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tablePayments,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Payment.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updatePayment(Payment payment) async {
    final db = await _dbHelper.database;
    return await db.update(
      DatabaseHelper.tablePayments,
      payment.toMap(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  Future<int> deletePayment(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DatabaseHelper.tablePayments,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalIncome() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM ${DatabaseHelper.tablePayments} WHERE isPaid = 1',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalPending() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM ${DatabaseHelper.tablePayments} WHERE isPaid = 0',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> getUnpaidPaymentCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.tablePayments} WHERE isPaid = 0',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
