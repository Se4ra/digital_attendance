import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:digital_attendance_system/helpers.dart'; // Keep this for the status badge
import 'attendance_record.dart'; // Import the AttendanceRecord model

class AttendanceListItem extends StatelessWidget {
  final AttendanceRecord record;
  final bool showCourseName;

  const AttendanceListItem({
    super.key,
    required this.record,
    this.showCourseName = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final DateFormat dateFormat = DateFormat('dd MMM yyyy'); // Consistent date format

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110, // Increased width for date
            child: Text(
              dateFormat.format(record.date), // Use record.date directly
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.studentName,
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      record.studentId,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                    if (showCourseName) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '- ${record.courseName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 60,
            child: Text(
              record.time,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Align(
              alignment: Alignment.center,
              child: getStatusBadge(record.status),
            ),
          ),
        ],
      ),
    );
  }
}

