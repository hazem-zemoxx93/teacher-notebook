import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teacher_notebook/providers/attendance_provider.dart';
import 'package:teacher_notebook/providers/group_provider.dart';
import 'package:teacher_notebook/providers/payment_provider.dart';
import 'package:teacher_notebook/providers/student_provider.dart';
import 'package:teacher_notebook/utils/app_routes.dart';
import 'package:teacher_notebook/widgets/dashboard_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    context.read<GroupProvider>().loadGroups();
    context.read<StudentProvider>().loadStudents();
    context.read<PaymentProvider>().loadPayments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دفتر المدرس'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'الإحصائيات',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _buildStatsGrid(context),
              const SizedBox(height: 24),
              Text(
                'العمليات السريعة',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _buildQuickActionsGrid(context),
            ],
          ),
        ),
      ),
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Consumer4<GroupProvider, StudentProvider, PaymentProvider, AttendanceProvider>(
      builder: (context, groupProvider, studentProvider, paymentProvider, attendanceProvider, _) {
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            DashboardCard(
              title: 'المجموعات',
              value: groupProvider.groups.length.toString(),
              icon: Icons.groups,
              color: const Color(0xFF1976D2),
              onTap: () => Navigator.pushNamed(context, AppRoutes.groups),
            ),
            DashboardCard(
              title: 'الطلاب',
              value: studentProvider.students.length.toString(),
              icon: Icons.person,
              color: const Color(0xFF388E3C),
              onTap: () => Navigator.pushNamed(context, AppRoutes.students),
            ),
            DashboardCard(
              title: 'الدفعات المقبولة',
              value: 'ر.س ${paymentProvider.totalIncome.toStringAsFixed(0)}',
              icon: Icons.money,
              color: const Color(0xFF00796B),
              onTap: () => Navigator.pushNamed(context, AppRoutes.payments),
            ),
            DashboardCard(
              title: 'المستحقات',
              value: 'ر.س ${paymentProvider.totalPending.toStringAsFixed(0)}',
              icon: Icons.pending_actions,
              color: const Color(0xFFC62828),
              onTap: () => Navigator.pushNamed(context, AppRoutes.payments),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _quickActionCard(
          context,
          'إضافة مجموعة',
          Icons.add_circle,
          const Color(0xFF1976D2),
          () => Navigator.pushNamed(context, AppRoutes.groups),
        ),
        _quickActionCard(
          context,
          'إضافة طالب',
          Icons.person_add,
          const Color(0xFF388E3C),
          () => Navigator.pushNamed(context, AppRoutes.students),
        ),
        _quickActionCard(
          context,
          'الحضور',
          Icons.check_circle,
          const Color(0xFFF57C00),
          () => Navigator.pushNamed(context, AppRoutes.attendance),
        ),
        _quickActionCard(
          context,
          'التقارير',
          Icons.assessment,
          const Color(0xFF00796B),
          () => Navigator.pushNamed(context, AppRoutes.reports),
        ),
      ],
    );
  }

  Widget _quickActionCard(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withOpacity(0.7)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book, size: 48, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'دفتر المدرس',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _drawerItem(
            context,
            Icons.dashboard,
            'اللوحة',
            () => Navigator.pop(context),
          ),
          _drawerItem(
            context,
            Icons.groups,
            'المجموعات',
            () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.groups);
            },
          ),
          _drawerItem(
            context,
            Icons.person,
            'الطلاب',
            () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.students);
            },
          ),
          _drawerItem(
            context,
            Icons.check_circle,
            'الحضور',
            () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.attendance);
            },
          ),
          _drawerItem(
            context,
            Icons.money,
            'الدفعات',
            () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.payments);
            },
          ),
          _drawerItem(
            context,
            Icons.assessment,
            'التقارير',
            () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.reports);
            },
          ),
          const Divider(),
          _drawerItem(
            context,
            Icons.settings,
            'الإعدادات',
            () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}
