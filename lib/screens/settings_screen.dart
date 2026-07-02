import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teacher_notebook/database/database_helper.dart';
import 'package:teacher_notebook/providers/theme_provider.dart';
import 'package:teacher_notebook/utils/app_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSectionTitle(context, 'العرض'),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return SwitchListTile(
                title: const Text('الوضع الليلي'),
                subtitle: const Text('بتفعيل الوضع الليلي لتقليل إجهاد العيون'),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.setDarkMode(value);
                },
              );
            },
          ),
          const Divider(),
          _buildSectionTitle(context, 'البيانات'),
          ListTile(
            leading: const Icon(Icons.backup, color: Colors.blue),
            title: const Text('حذف جميع البيانات'),
            subtitle: const Text('حذف كل البيانات بشكل نهايئي'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => _showDeleteConfirmation(context),
          ),
          const Divider(),
          _buildSectionTitle(context, 'حول التطبيق'),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.green),
            title: const Text('معلومات عن التطبيق'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => _showAboutDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.rate_review, color: Colors.orange),
            title: const Text('فرصة التقييم'),
            subtitle: const Text('قيم التطبيق على متجر بلاي'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              AppUtils.showSnackBar(context, 'شكرا لتقييمك 🙋');
            },
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'إصدار 1.0.0',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    AppUtils.showConfirmDialog(
      context,
      'تحذير',
      'هل أنت متأكد من حذف جميع البيانات؟ \nهذه العملية لا يمكن التراجع عنها!',
      () async {
        await DatabaseHelper.instance.deleteAllData();
        if (mounted) {
          AppUtils.showSnackBar(context, 'تم حذف جميع البيانات بنجاح');
        }
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('دفتر المدرس'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ما هو هذا التطبيق؟',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'تطبيق موبيل مختص للمعلمين والمدربين لإدارة المجموعات والطلاب والحضور والدفعات.',
              ),
              SizedBox(height: 16),
              Text(
                'الميزات:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• إدارة مرنة للمجموعات\n'
                '• تتبع للطلاب ومعلوماتهم\n'
                '• تسجيل الحضور\n'
                '• إدارة الدفعات\n'
                '• تقارير مفصلة\n'
                '• وضع ليلي',
              ),
              SizedBox(height: 16),
              Text(
                'الإصدار: 1.0.0',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسنا'),
          ),
        ],
      ),
    );
  }
}
