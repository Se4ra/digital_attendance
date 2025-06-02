
import 'package:intl/intl.dart';

// Format date as 'MMM d, yyyy' (e.g., Jul 15, 2024)
String formatDate(DateTime date) {
  return DateFormat('MMM d, yyyy').format(date);
}

// Format date as 'EEEE, MMMM d, yyyy' (e.g., Monday, July 15, 2024)
String formatFullDate(DateTime date) {
  return DateFormat('EEEE, MMMM d, yyyy').format(date);
}

// Format time (assuming HH:MM string input) - simple pass-through for now
String formatTime(String time) {
  // Could parse and format if needed, but assuming input is already formatted
  return time;
}

// Get day abbreviation (e.g., Mon, Tue)
String getDayAbbreviation(DateTime date) {
  return DateFormat('E').format(date); // 'E' gives abbreviated day name
}
