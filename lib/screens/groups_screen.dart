import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teacher_notebook/models/group_model.dart';
import 'package:teacher_notebook/providers/group_provider.dart';
import 'package:teacher_notebook/utils/app_utils.dart';
import 'package:teacher_notebook/widgets/app_bar_with_search.dart';
import 'package:teacher_notebook/widgets/group_card.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GroupProvider>().loadGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المجموعات'),
        elevation: 0,
      ),
      body: Consumer<GroupProvider>(
        builder: (context, groupProvider, _) {
          if (groupProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (groupProvider.groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.groups, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد مجموعات',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: groupProvider.groups.length,
            itemBuilder: (context, index) {
              final group = groupProvider.groups[index];
              return FutureBuilder<int>(
                future: groupProvider.getGroupStudentCount(group.id!),
                builder: (context, snapshot) {
                  final studentCount = snapshot.data ?? 0;
                  return GroupCard(
                    groupName: group.name,
                    subject: group.subject,
                    schedule: group.schedule,
                    studentCount: studentCount,
                    monthlyFee: group.monthlyFee,
                    onEdit: () => _showGroupDialog(context, groupProvider, group),
                    onDelete: () => _confirmDelete(context, groupProvider, group.id!),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGroupDialog(context, context.read<GroupProvider>()),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showGroupDialog(BuildContext context, GroupProvider provider, [Group? group]) {
    final nameController = TextEditingController(text: group?.name ?? '');
    final subjectController = TextEditingController(text: group?.subject ?? '');
    final scheduleController = TextEditingController(text: group?.schedule ?? '');
    final feeController = TextEditingController(text: group?.monthlyFee.toString() ?? '');
    final notesController = TextEditingController(text: group?.notes ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(group == null ? 'إضافة مجموعة' : 'تعديل المجموعة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم المجموعة'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(labelText: 'المادة'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: scheduleController,
                decoration: const InputDecoration(labelText: 'الوقت'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: feeController,
                decoration: const InputDecoration(labelText: 'الرسوم الشهرية'),
                keyboardType: TextInputType.number,
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || subjectController.text.isEmpty) {
                AppUtils.showErrorDialog(context, 'خطأ', 'يرجى ملء الحقول المطلوبة');
                return;
              }

              final newGroup = Group(
                id: group?.id,
                name: nameController.text,
                subject: subjectController.text,
                schedule: scheduleController.text,
                monthlyFee: double.tryParse(feeController.text) ?? 0,
                notes: notesController.text,
                createdAt: group?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
              );

              bool success;
              if (group == null) {
                success = await provider.addGroup(newGroup);
              } else {
                success = await provider.updateGroup(newGroup);
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

  void _confirmDelete(BuildContext context, GroupProvider provider, int id) {
    AppUtils.showConfirmDialog(
      context,
      'حذف المجموعة',
      'هل أنت متأكد من حذف هذه المجموعة؟',
      () async {
        final success = await provider.deleteGroup(id);
        if (success && mounted) {
          AppUtils.showSnackBar(context, 'تم حذف المجموعة بنجاح');
        }
      },
    );
  }
}
