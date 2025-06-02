import 'package:flutter/material.dart';
import 'dart:math' show min;
import 'Lecturer/attendance_record.dart';

String getInitials(String name) {
  if (name.trim().isEmpty) return '?';
  List<String> parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length > 1) {
    return '${parts.first[0].toUpperCase()}${parts.last[0].toUpperCase()}';
  } else {
    String firstPart = parts[0];
    return firstPart.substring(0, min(2, firstPart.length)).toUpperCase();
  }
}

Widget getStatusIcon(AttendanceStatus status, {double size = 20.0}) {
  switch (status) {
    case AttendanceStatus.attended:
      return Icon(Icons.check_circle, color: Colors.green, size: size);
    case AttendanceStatus.absent:
      return Icon(Icons.cancel, color: Colors.red, size: size);
    case AttendanceStatus.pending:
      return Icon(Icons.schedule, color: Colors.grey, size: size);
  }
}

Widget getStatusBadge(AttendanceStatus status) {
  late final Color backgroundColor;
  late final Color textColor;
  late final String label;

  switch (status) {
    case AttendanceStatus.attended:
      backgroundColor = Colors.green.shade100;
      textColor = Colors.green.shade800;
      label = 'Attended';
      break;
    case AttendanceStatus.absent:
      backgroundColor = Colors.red.shade100;
      textColor = Colors.red.shade800;
      label = 'Absent';
      break;
    case AttendanceStatus.pending:
      backgroundColor = Colors.grey.shade300;
      textColor = Colors.black54;
      label = 'Pending';
      break;
  }

  return Chip(
    label: Text(
      label,
      style: TextStyle(
        color: textColor,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    backgroundColor: backgroundColor,
    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
    labelPadding: EdgeInsets.zero,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
  );
}
