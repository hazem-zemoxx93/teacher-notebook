import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:teacher_notebook/database/database_helper.dart';

class AppProvider extends ChangeNotifier {
  bool _isBackupLoading = false;
  String? _backupError;
  String? _backupSuccess;

  bool get isBackupLoading => _isBackupLoading;
  String? get backupError => _backupError;
  String? get backupSuccess => _backupSuccess;

  Future<void> deleteAllData() async {
    try {
      await DatabaseHelper.instance.deleteAllData();
      _backupSuccess = 'تم حذف جميع البيانات بنجاح';
      notifyListeners();
    } catch (e) {
      _backupError = e.toString();
      notifyListeners();
    }
  }
}
