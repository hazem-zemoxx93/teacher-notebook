import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  bool _isBackupLoading = false;
  String? _backupError;
  String? _backupSuccess;

  bool get isBackupLoading => _isBackupLoading;
  String? get backupError => _backupError;
  String? get backupSuccess => _backupSuccess;
}
