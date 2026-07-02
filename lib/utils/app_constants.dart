import 'package:intl/intl.dart';

class AppConstants {
  static const String appName = 'دفتر المدرس';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Teacher Notebook - التطبيق المختص لإدارة الطلاب';

  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: 'ر.س', decimalDigits: 2);
    return formatter.format(amount);
  }

  static String formatDate(DateTime date) {
    final formatter = DateFormat('yyyy-MM-dd', 'ar');
    return formatter.format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('yyyy-MM-dd HH:mm', 'ar');
    return formatter.format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    final formatter = DateFormat('HH:mm', 'ar');
    return formatter.format(dateTime);
  }
}
