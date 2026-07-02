import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teacher_notebook/models/attendance_model.dart';
import 'package:teacher_notebook/models/lesson_model.dart';
import 'package:teacher_notebook/providers/attendance_provider.dart';
import 'package:teacher_notebook/providers/group_provider.dart';
import 'package:teacher_notebook/providers/student_provider.dart';
import 'package:teacher_notebook/utils/app_utils.dart';
import 'package:teacher_notebook/widgets/attendance_item.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  int? _selectedGroupId;
  int? _selectedLessonId;
  final Map<int, bool> _attendanceMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الحضور'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Consumer<GroupProvider>(
                  builder: (context, groupProvider, _) {
                    return DropdownButton<int>(
                      isExpanded: true,
                      value: _selectedGroupId,
                      hint: const Text('اختر المجموعة'),
                      items: groupProvider.groups
                          .map((g) => DropdownMenuItem(value: g.id, child: Text(g.name)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGroupId = value;
                          _selectedLessonId = null;
                        });
                        if (value != null) {
                          context.read<AttendanceProvider>().loadLessonsByGroup(value);
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                if (_selectedGroupId != null)
                  Consumer<AttendanceProvider>(
                    builder: (context, attendanceProvider, _) {
                      return DropdownButton<int>(
                        isExpanded: true,
                        value: _selectedLessonId,
                        hint: const Text('اختر الدرس'),
                        items: attendanceProvider.lessons
                            .map((l) => DropdownMenuItem(
                                  value: l.id,
                                  child: Text('${l.topic} - ${l.date.toLocal()}'),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLessonId = value;
                            _attendanceMap.clear();
                          });
                        },
                      );
                    },
                  ),
                const SizedBox(height: 16),
                if (_selectedLessonId != null)
                  ElevatedButton(
                    onPressed: () => _createNewLesson(context),
                    child: const Text('إضافة درس جديد'),
                  ),
              ],
            ),
          ),
          if (_selectedLessonId != null)
            Expanded(
              child: _buildAttendanceList(context),
            ),
        ],
      ),
      floatingActionButton: _selectedLessonId != null
          ? FloatingActionButton(
              onPressed: () => _saveAttendance(context),
              child: const Icon(Icons.save),
            )
          : null,
    );
  }

  Widget _buildAttendanceList(BuildContext context) {
    return Consumer2<StudentProvider, AttendanceProvider>(
      builder: (context, studentProvider, attendanceProvider, _) {
        final students = studentProvider.students
            .where((s) => s.groupId == _selectedGroupId)
            .toList();

        if (students.isEmpty) {
          return const Center(
            child: Text('لا يوجد طلاب لهذه المجموعة'),
          );
        }

        return ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return AttendanceItem(
              studentName: student.fullName,
              isPresent: _attendanceMap[student.id!] ?? false,
              onToggle: () {
                setState(() {
                  _attendanceMap[student.id!] = !(_attendanceMap[student.id!] ?? false);
                });
              },
            );
          },
        );
      },
    );
  }

  void _createNewLesson(BuildContext context) {
    final topicController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة درس جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: topicController,
              decoration: const InputDecoration(labelText: 'موضوع الدرس'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'ملاحظات'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (topicController.text.isEmpty) {
                AppUtils.showErrorDialog(context, 'خطأ', 'يرجى إدخال موضوع الدرس');
                return;
              }

              final lesson = Lesson(
                groupId: _selectedGroupId!,
                date: DateTime.now(),
                topic: topicController.text,
                notes: notesController.text,
                createdAt: DateTime.now(),
              );

              final success = await context.read<AttendanceProvider>().createLesson(lesson);
              if (success && mounted) {
                Navigator.pop(context);
                await context.read<AttendanceProvider>().loadLessonsByGroup(_selectedGroupId!);
                setState(() => _attendanceMap.clear());
                AppUtils.showSnackBar(context, 'تم إضافة الدرس بنجاح');
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAttendance(BuildContext context) async {
    final attendanceProvider = context.read<AttendanceProvider>();
    final studentProvider = context.read<StudentProvider>();

    final students = studentProvider.students
        .where((s) => s.groupId == _selectedGroupId)
        .toList();

    int savedCount = 0;
    for (final student in students) {
      final isPresent = _attendanceMap[student.id!] ?? false;
      final attendance = Attendance(
        studentId: student.id!,
        lessonId: _selectedLessonId!,
        isPresent: isPresent,
        recordedAt: DateTime.now(),
      );

      final success = await attendanceProvider.recordAttendance(attendance);
      if (success) savedCount++;
    }

    if (mounted) {
      AppUtils.showSnackBar(context, 'تم حفظ $savedCount سجل حضور');
      setState(() {
        _selectedLessonId = null;
        _attendanceMap.clear();
      });
    }
  }
}
