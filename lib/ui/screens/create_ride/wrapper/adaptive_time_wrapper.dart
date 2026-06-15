import 'package:flutter/material.dart';

import '../widgets/time_picker_for_ride.dart';
class AdaptiveDateTimePickerField extends StatefulWidget {
  final DateTime? initialDateTime;
  final ValueChanged<DateTime>? onDateTimeChanged;
  final String? label;
  final String? hintText;
  final bool use24HourFormat;
  final InputDecoration? decoration;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTimePickerMode mode;

  const AdaptiveDateTimePickerField({
    super.key,
    this.initialDateTime,
    this.onDateTimeChanged,
    this.label,
    this.hintText,
    this.use24HourFormat = false,
    this.decoration,
    this.firstDate,
    this.lastDate,
    this.mode = DateTimePickerMode.dateTime,
  });

  @override
  State<AdaptiveDateTimePickerField> createState() => _AdaptiveDateTimePickerFieldState();
}

class _AdaptiveDateTimePickerFieldState extends State<AdaptiveDateTimePickerField> {
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initialDateTime;
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveDateTimePicker(
      initialDateTime: _selectedDateTime,
      label: widget.label,
      hintText: widget.hintText,
      use24HourFormat: widget.use24HourFormat,
      decoration: widget.decoration,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      mode: widget.mode,
      onDateTimeSelected: (DateTime dateTime) {
        setState(() {
          _selectedDateTime = dateTime;
        });
        widget.onDateTimeChanged?.call(dateTime);
      },
    );
  }
}