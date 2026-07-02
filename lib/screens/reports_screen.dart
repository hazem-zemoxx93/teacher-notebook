import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teacher_notebook/providers/attendance_provider.dart';
import 'package:teacher_notebook/providers/group_provider.dart';
import 'package:teacher_notebook/providers/payment_provider.dart';
import 'package:teacher_notebook/providers/student_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    context.read<GroupProvider>().loadGroups();
    context.read<StudentProvider>().loadStudents();
    context.read<PaymentProvider>().loadPayments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadReportData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFinancialSummary(context),
              const SizedBox(height: 24),
              _buildStudentStatistics(context),
              const SizedBox(height: 24),
              _buildGroupStatistics(context),
              const SizedBox(height: 24),
              _buildPaymentSummary(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialSummary(BuildContext context) {
    return Consumer<PaymentProvider>(
      builder: (context, paymentProvider, _) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ملخص مالي',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                _reportRow(
                  context,
                  'إجمالي المدفوعات',
                  'ر.س ${paymentProvider.totalIncome.toStringAsFixed(2)}',
                  Colors.green,
                ),
                const SizedBox(height: 8),
                _reportRow(
                  context,
                  'إجمالي المستحقات',
                  'ر.س ${paymentProvider.totalPending.toStringAsFixed(2)}',
                  Colors.red,
                ),
                const SizedBox(height: 8),
                _reportRow(
                  context,
                  'الإجمالي',
                  'ر.س ${(paymentProvider.totalIncome + paymentProvider.totalPending).toStringAsFixed(2)}',
                  Colors.blue,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudentStatistics(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, studentProvider, _) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إحصائيات الطلاب',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                _reportRow(
                  context,
                  'إجمالي عدد الطلاب',
                  studentProvider.students.length.toString(),
                  Colors.blue,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupStatistics(BuildContext context) {
    return Consumer2<GroupProvider, StudentProvider>(
      builder: (context, groupProvider, studentProvider, _) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إحصائيات المجموعات',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                _reportRow(
                  context,
                  'عدد المجموعات',
                  groupProvider.groups.length.toString(),
                  Colors.green,
                ),
                const SizedBox(height: 16),
                ...groupProvider.groups.map((group) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _groupStatRow(
                    context,
                    group.name,
                    group.subject,
                    group.monthlyFee,
                  ),
                )).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentSummary(BuildContext context) {
    return Consumer<PaymentProvider>(
      builder: (context, paymentProvider, _) {
        final paidCount = paymentProvider.payments.where((p) => p.isPaid).length;
        final unpaidCount = paymentProvider.payments.where((p) => !p.isPaid).length;
        final totalPayments = paymentProvider.payments.length;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ملخص الدفعات',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                _reportRow(context, 'إجمالي الدفعات', totalPayments.toString(), Colors.blue),
                const SizedBox(height: 8),
                _reportRow(context, 'الدفعات المدفوعة', paidCount.toString(), Colors.green),
                const SizedBox(height: 8),
                _reportRow(context, 'الدفعات المعلقة', unpaidCount.toString(), Colors.orange),
                if (totalPayments > 0) ...[const SizedBox(height: 8),
                  _reportRow(
                    context,
                    'نسبة المدفوعات',
                    '${((paidCount / totalPayments) * 100).toStringAsFixed(1)}%',
                    Colors.teal,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _reportRow(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _groupStatRow(
    BuildContext context,
    String groupName,
    String subject,
    double fee,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            groupName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subject, style: const TextStyle(fontSize: 12)),
              Text(
                'ر.س $fee',
                style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
