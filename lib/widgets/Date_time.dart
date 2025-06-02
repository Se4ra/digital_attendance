import 'package:intl/intl.dart';

void main() {
  // Get the current date and time.
  DateTime now = DateTime.now();
  print('Current date and time: $now');

  // Create a specific date and time.
  DateTime specificDate = DateTime(2024, 1, 15, 9, 30); // Year, Month, Day, Hour, Minute
  print('Specific date and time: $specificDate');

  // Create a date with only year, month, and day.
  DateTime dateOnly = DateTime(2024, 1, 15);
  print('Date only: $dateOnly'); // Time defaults to 00:00:00.000

  // Parse a date string.
  DateTime parsedDate = DateTime.parse('2024-02-20 14:15:00');
  print('Parsed date: $parsedDate');

  // Format the DateTime object.
  String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
  print('Formatted date: $formattedDate'); // e.g., 2024-05-24 - 10:23 (24-hour format)

  String formattedDate2 = DateFormat('dd/MM/yyyy hh:mm a').format(now);
  print('Formatted date: $formattedDate2'); // e.g., 24/05/2024 10:23 AM (12-hour format)

  // Get individual components.
  int year = now.year;
  int month = now.month;
  int day = now.day;
  int hour = now.hour;
  int minute = now.minute;
  int second = now.second;
  int millisecond = now.millisecond;
  int microsecond = now.microsecond;

  print('Year: $year, Month: $month, Day: $day, Hour: $hour, Minute: $minute, Second: $second, Millisecond: $millisecond, Microsecond: $microsecond');

  // Perform date calculations.
  DateTime tomorrow = now.add(const Duration(days: 1));
  print('Tomorrow: $tomorrow');

  DateTime yesterday = now.subtract(const Duration(days: 1));
  print('Yesterday: $yesterday');

  Duration difference = now.difference(specificDate);
  print('Difference between now and specificDate: $difference'); //prints in days, hours, minutes and seconds

  // Compare dates.
  bool isAfter = now.isAfter(specificDate);
  bool isBefore = now.isBefore(specificDate);
  bool isAtSameMomentAs = now.isAtSameMomentAs(specificDate);

  print('Is now after specificDate? $isAfter');
  print('Is now before specificDate? $isBefore');
  print('Is now at the same moment as specificDate? $isAtSameMomentAs');

  // Get the time zone
  String timeZoneName = now.timeZoneName;
  print('Time zone name: $timeZoneName');

  // Get the time zone offset
  Duration timeZoneOffset = now.timeZoneOffset;
  print('Time zone offset: $timeZoneOffset');
}
