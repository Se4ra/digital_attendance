
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangePickerButton extends StatelessWidget {
  final DateTimeRange? selectedDateRange;
  final ValueChanged<DateTimeRange?> onDateRangeSelected;
  final String buttonText;

  const DateRangePickerButton({
    super.key,
    required this.selectedDateRange,
    required this.onDateRangeSelected,
    this.buttonText = 'Select Date Range',
  });

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: selectedDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 7)), // Default to last 7 days
            end: DateTime.now(),
          ),
      firstDate: DateTime(DateTime.now().year - 1), // Allow selecting from last year
      lastDate: DateTime(DateTime.now().year + 1), // Allow selecting up to next year
      builder: (context, child) {
        // Apply theme customization if needed
        return Theme(
          data: Theme.of(context).copyWith(
            // Customize picker colors here if necessary, e.g.:
            // colorScheme: Theme.of(context).colorScheme.copyWith(
            //   primary: Colors.yourPrimaryColor,
            //   onPrimary: Colors.white,
            // ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDateRange) {
      onDateRangeSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayText;
    if (selectedDateRange != null) {
      final startFormatted = DateFormat('MMM d, y').format(selectedDateRange!.start);
      final endFormatted = DateFormat('MMM d, y').format(selectedDateRange!.end);
      displayText = '$startFormatted - $endFormatted';
    } else {
      displayText = buttonText;
    }

    return OutlinedButton.icon(
      icon: const Icon(Icons.calendar_month_outlined, size: 18),
      label: Text(
        displayText,
        style: TextStyle(
          color: selectedDateRange != null ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.outline, // Indicate if set
        ),
        overflow: TextOverflow.ellipsis,
      ),
      onPressed: () => _selectDateRange(context),
      style: OutlinedButton.styleFrom(
        // padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        textStyle: const TextStyle(fontSize: 14),
        foregroundColor: Theme.of(context).colorScheme.onSurface, // Use consistent text color
        side: BorderSide(color: Theme.of(context).colorScheme.outline), // Use theme border color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
