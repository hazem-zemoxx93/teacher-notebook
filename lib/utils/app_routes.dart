import 'package:flutter/material.dart';
import 'package:teacher_notebook/screens/attendance_screen.dart';
import 'package:teacher_notebook/screens/dashboard_screen.dart';
import 'package:teacher_notebook/screens/groups_screen.dart';
import 'package:teacher_notebook/screens/payments_screen.dart';
import 'package:teacher_notebook/screens/reports_screen.dart';
import 'package:teacher_notebook/screens/settings_screen.dart';
import 'package:teacher_notebook/screens/students_screen.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String groups = '/groups';
  static const String students = '/students';
  static const String attendance = '/attendance';
  static const String payments = '/payments';
  static const String reports = '/reports';
  static const String settings = '/settings';

  static final Map<String, WidgetBuilder> routes = {
    dashboard: (context) => const DashboardScreen(),
    groups: (context) => const GroupsScreen(),
    students: (context) => const StudentsScreen(),
    attendance: (context) => const AttendanceScreen(),
    payments: (context) => const PaymentsScreen(),
    reports: (context) => const ReportsScreen(),
    settings: (context) => const SettingsScreen(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => const DashboardScreen(),
    );
  }
}
