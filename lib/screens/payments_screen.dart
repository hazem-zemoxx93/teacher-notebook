import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teacher_notebook/models/payment_model.dart';
import 'package:teacher_notebook/providers/group_provider.dart';
import 'package:teacher_notebook/providers/payment_provider.dart';
import 'package:teacher_notebook/providers/student_provider.dart';
import 'package:teacher_notebook/utils/app_utils.dart';
import 'package:teacher_notebook/widgets/payment_card.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({Key? key}) : super(key: key);

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<PaymentProvider>().loadPayments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدفعات'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'المعلقة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllPaymentsTab(context),
          _buildUnpaidPaymentsTab(context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPaymentDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAllPaymentsTab(BuildContext context) {
    return Consumer2<PaymentProvider, StudentProvider>(
      builder: (context, paymentProvider, studentProvider, _) {
        if (paymentProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (paymentProvider.payments.isEmpty) {
          return const Center(child: Text('لا توجد دفعات'));
        }

        return ListView(
          padding: const EdgeInsets.all(8),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المدفوع: ${paymentProvider.totalIncome.toStringAsFixed(0)} ر.س',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'المعلق: ${paymentProvider.totalPending.toStringAsFixed(0)} ر.س',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            ...paymentProvider.payments.map((payment) {
              final student = studentProvider.students
                  .firstWhere((s) => s.id == payment.studentId);
              return PaymentCard(
                studentName: student.fullName,
                amount: payment.amount,
                dueDate: payment.dueDate,
                isPaid: payment.isPaid,
                onMarkPaid: () => _markPaymentPaid(context, paymentProvider, payment),
                onDelete: () => _deletePayment(context, paymentProvider, payment.id!),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildUnpaidPaymentsTab(BuildContext context) {
    return Consumer2<PaymentProvider, StudentProvider>(
      builder: (context, paymentProvider, studentProvider, _) {
        if (paymentProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (paymentProvider.unpaidPayments.isEmpty) {
          return const Center(child: Text('لا توجد دفعات معلقة'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: paymentProvider.unpaidPayments.length,
          itemBuilder: (context, index) {
            final payment = paymentProvider.unpaidPayments[index];
            final student = studentProvider.students
                .firstWhere((s) => s.id == payment.studentId);
            return PaymentCard(
              studentName: student.fullName,
              amount: payment.amount,
              dueDate: payment.dueDate,
              isPaid: payment.isPaid,
              onMarkPaid: () => _markPaymentPaid(context, paymentProvider, payment),
              onDelete: () => _deletePayment(context, paymentProvider, payment.id!),
            );
          },
        );
      },
    );
  }

  void _showAddPaymentDialog(BuildContext context) {
    int? selectedStudentId;
    final amountController = TextEditingController();
    DateTime? selectedDate = DateTime.now();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('إضافة دفعة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<StudentProvider>(
                  builder: (context, studentProvider, _) {
                    return DropdownButton<int>(
                      isExpanded: true,
                      value: selectedStudentId,
                      hint: const Text('اختر الطالب'),
                      items: studentProvider.students
                          .map((s) => DropdownMenuItem(value: s.id, child: Text(s.fullName)))
                          .toList(),
                      onChanged: (value) {
                        setStateDialog(() => selectedStudentId = value);
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'المبلغ'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Date: ${selectedDate?.toLocal().toString().split(' ')[0]}',
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate!,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setStateDialog(() => selectedDate = date);
                        }
                      },
                      child: const Text('اختر'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'ملاحظات'),
                  maxLines: 2,
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
                if (selectedStudentId == null || amountController.text.isEmpty) {
                  AppUtils.showErrorDialog(context, 'خطأ', 'يرجى ملء الحقول المطلوبة');
                  return;
                }

                final student = context.read<StudentProvider>().students
                    .firstWhere((s) => s.id == selectedStudentId);

                final payment = Payment(
                  studentId: selectedStudentId!,
                  groupId: student.groupId,
                  amount: double.parse(amountController.text),
                  dueDate: selectedDate!,
                  notes: notesController.text,
                  createdAt: DateTime.now(),
                );

                final success = await context.read<PaymentProvider>().addPayment(payment);
                if (success && mounted) {
                  Navigator.pop(context);
                  AppUtils.showSnackBar(context, 'تم إضافة الدفعة بنجاح');
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _markPaymentPaid(BuildContext context, PaymentProvider provider, Payment payment) {
    final updatedPayment = payment.copyWith(
      isPaid: true,
      paidDate: DateTime.now(),
    );

    AppUtils.showConfirmDialog(
      context,
      'تأكيد الدفع',
      'هل تريد أن تعلم هذه الدفعة كمدفوعة؟',
      () async {
        final success = await provider.updatePayment(updatedPayment);
        if (success && mounted) {
          AppUtils.showSnackBar(context, 'تم تحديث حالة الدفع');
        }
      },
    );
  }

  void _deletePayment(BuildContext context, PaymentProvider provider, int id) {
    AppUtils.showConfirmDialog(
      context,
      'حذف الدفعة',
      'هل أنت متأكد من حذف هذه الدفعة؟',
      () async {
        final success = await provider.deletePayment(id);
        if (success && mounted) {
          AppUtils.showSnackBar(context, 'تم حذف الدفعة بنجاح');
        }
      },
    );
  }
}
