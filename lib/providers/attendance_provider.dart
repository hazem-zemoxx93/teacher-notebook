import 'package:flutter/material.dart';
import 'package:teacher_notebook/models/attendance_model.dart';
import 'package:teacher_notebook/models/lesson_model.dart';
import 'package:teacher_notebook/repositories/attendance_repository.dart';
import 'package:teacher_notebook/repositories/lesson_repository.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceRepository _repository = AttendanceRepository();
  final LessonRepository _lessonRepository = LessonRepository();
  List<Attendance> _attendances = [];
  List<Lesson> _lessons = [];
  bool _isLoading = false;
  String? _error;

  List<Attendance> get attendances => _attendances;
  List<Lesson> get lessons => _lessons;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAttendanceByLesson(int lessonId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _attendances = await _repository.getAttendanceByLesson(lessonId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLessonsByGroup(int groupId) async {
    try {
      _lessons = await _lessonRepository.getLessonsByGroup(groupId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> recordAttendance(Attendance attendance) async {
    try {
      await _repository.insertAttendance(attendance);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> createLesson(Lesson lesson) async {
    try {
      await _lessonRepository.insertLesson(lesson);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<double> getStudentAttendancePercentage(int studentId) async {
    return await _repository.getStudentAttendancePercentage(studentId);
  }

  Future<List<Attendance>> getStudentAttendance(int studentId) async {
    return await _repository.getStudentAttendance(studentId);
  }
}
