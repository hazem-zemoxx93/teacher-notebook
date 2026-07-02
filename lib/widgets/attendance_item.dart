import 'package:flutter/material.dart';

class AttendanceItem extends StatelessWidget {
  final String studentName;
  final bool isPresent;
  final VoidCallback onToggle;

  const AttendanceItem({
    Key? key,
    required this.studentName,
    required this.isPresent,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(studentName),
      trailing: GestureDetector(
        onTap: onToggle,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isPresent ? Colors.green[50] : Colors.red[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isPresent ? Colors.green : Colors.red,
            ),
          ),
          child: Icon(
            isPresent ? Icons.check : Icons.close,
            color: isPresent ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}
