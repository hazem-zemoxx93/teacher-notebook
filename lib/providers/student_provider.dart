import 'package:flutter/material.dart';
import 'package:teacher_notebook/models/student_model.dart';
import 'package:teacher_notebook/repositories/student_repository.dart';

class StudentProvider extends ChangeNotifier {
  final StudentRepository _repository = StudentRepository();
  List<Student> _students = [];
  List<Student> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  List<Student> get students => _students;
  List<Student> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStudents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _students = await _repository.getAllStudents();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Student>> getStudentsByGroup(int groupId) async {
    try {
      return await _repository.getStudentsByGroup(groupId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<void> searchStudents(String query) async {
    try {
      _searchResults = await _repository.searchStudents(query);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addStudent(Student student) async {
    try {
      await _repository.insertStudent(student);
      await loadStudents();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStudent(Student student) async {
    try {
      await _repository.updateStudent(student);
      await loadStudents();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deactivateStudent(int id) async {
    try {
      await _repository.deactivateStudent(id);
      await loadStudents();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<int> getTotalStudentCount() async {
    return await _repository.getTotalStudentCount();
  }
}
