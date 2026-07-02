import 'package:flutter/material.dart';
import 'package:teacher_notebook/models/group_model.dart';
import 'package:teacher_notebook/repositories/group_repository.dart';

class GroupProvider extends ChangeNotifier {
  final GroupRepository _repository = GroupRepository();
  List<Group> _groups = [];
  bool _isLoading = false;
  String? _error;

  List<Group> get groups => _groups;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadGroups() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _groups = await _repository.getAllGroups();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addGroup(Group group) async {
    try {
      await _repository.insertGroup(group);
      await loadGroups();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateGroup(Group group) async {
    try {
      await _repository.updateGroup(group);
      await loadGroups();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteGroup(int id) async {
    try {
      await _repository.deleteGroup(id);
      await loadGroups();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<int> getGroupStudentCount(int groupId) async {
    return await _repository.getGroupStudentCount(groupId);
  }
}
