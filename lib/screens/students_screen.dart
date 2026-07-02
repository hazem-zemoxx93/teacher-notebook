import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teacher_notebook/models/student_model.dart';
import 'package:teacher_notebook/providers/group_provider.dart';
import 'package:teacher_notebook/providers/student_provider.dart';
import 'package:teacher_notebook/utils/app_utils.dart';
import 'package:teacher_notebook/widgets/app_bar_with_search.dart';
import 'package:teacher_notebook/widgets/student_card.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({Key? key}) : super(key: key);

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<StudentProvider>().loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithSearch(
        title: 'الطلاب',
        onSearchChanged: (query) {
          setState(() => _searchQuery = query);
          if (query.isNotEmpty) {
            context.read<StudentProvider>().searchStudents(query);
          } else {
            context.read<StudentProvider>().loadStudents();
          }
        },
      ),
      body: Consumer2<StudentProvider, GroupProvider>(
        builder: (context, studentProvider, groupProvider, _) {
          if (studentProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final students = _searchQuery.isNotEmpty
              ? studentProvider.searchResults
              : studentProvider.students;

          if (students.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'لا يوجد طلاب',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final group = groupProvider.groups
                  .firstWhere((g) => g.id == student.groupId);

              return StudentCard(
                fullName: student.fullName,
                phoneNumber: student.phoneNumber,
                parentPhone: student.parentPhone,
                groupName: group.name,
                onEdit: () => _showStudentDialog(context, context.read<StudentProvider>(), student),
                onDelete: () => _confirmDelete(context, context.read<StudentProvider>(), student.id!),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStudentDialog(context, context.read<StudentProvider>()),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showStudentDialog(
    BuildContext context,
    StudentProvider provider,
    [Student? student],
  ) {
    final nameController = TextEditingController(text: student?.fullName ?? '');
    final phoneController = TextEditingController(text: student?.phoneNumber ?? '');
    final parentPhoneController = TextEditingController(text: student?.parentPhone ?? '');
    final notesController = TextEditingController(text: student?.notes ?? '');
    int? selectedGroupId = student?.groupId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(student == null ? 'إضافة طالب' : 'تعديل الطالب'),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setStateDialog) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: parentPhoneController,
                  decoration: const InputDecoration(labelText: 'رقم هاتف الوالد'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                Consumer<GroupProvider>(
                  builder: (context, groupProvider, _) {
                    return DropdownButton<int>(
                      isExpanded: true,
                      value: selectedGroupId,
                      hint: const Text('اختر المجموعة'),
                      items: groupProvider.groups
                          .map((g) => DropdownMenuItem(value: g.id, child: Text(g.name)))
                          .toList(),
                      onChanged: (value) {
                        setStateDialog(() => selectedGroupId = value);
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'ملاحظات'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || phoneController.text.isEmpty || selectedGroupId == null) {
                AppUtils.showErrorDialog(context, 'خطأ', 'يرجى ملء الحقول المطلوبة');
                return;
              }

              final newStudent = Student(
                id: student?.id,
                fullName: nameController.text,
                phoneNumber: phoneController.text,
                parentPhone: parentPhoneController.text.isEmpty ? null : parentPhoneController.text,
                groupId: selectedGroupId!,
                notes: notesController.text,
                createdAt: student?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
              );

              bool success;
              if (student == null) {
                success = await provider.addStudent(newStudent);
              } else {
                success = await provider.updateStudent(newStudent);
              }

              if (success) {
                if (mounted) {
                  Navigator.pop(context);
                  AppUtils.showSnackBar(context, 'تم الحفظ بنجاح');
                }
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, StudentProvider provider, int id) {
    AppUtils.showConfirmDialog(
      context,
      'حذف الطالب',
      'هل أنت متأكد من حذف هذا الطالب؟',
      () async {
        final success = await provider.deactivateStudent(id);
        if (success && mounted) {
          AppUtils.showSnackBar(context, 'تم حذف الطالب بنجاح');
        }
      },
    );
  }
}
