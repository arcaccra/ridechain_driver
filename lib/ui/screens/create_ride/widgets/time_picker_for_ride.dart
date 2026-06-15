
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:intl/intl.dart';
import 'package:ridechain_driiver/core/core_constants/colors.dart';

import '../../../../app/theme.dart';
import '../../../../core/core_constants/label.dart';

/// Adaptive DateTime Picker that uses Cupertino style on iOS and Material style on Android
class AdaptiveDateTimePicker extends StatelessWidget {
  final DateTime? initialDateTime;
  final ValueChanged<DateTime>? onDateTimeSelected;
  final String? label;
  final String? hintText;
  final bool use24HourFormat;
  final InputDecoration? decoration;
  final TextStyle? textStyle;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTimePickerMode mode; // date, time, or dateTime

  const AdaptiveDateTimePicker({
    Key? key,
    this.initialDateTime,
    this.onDateTimeSelected,
    this.label,
    this.hintText = 'Select date and time',
    this.use24HourFormat = false,
    this.decoration,
    this.textStyle,
    this.firstDate,
    this.lastDate,
    this.mode = DateTimePickerMode.dateTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedDateTime = initialDateTime ?? DateTime.now();
    final displayText = _formatDateTime(selectedDateTime);

    return InkWell(
      onTap: () => _showDateTimePicker(context, selectedDateTime),
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: decoration ??
            InputDecoration(
              labelText: label,
              hintText: hintText,
              labelStyle: AppThemes.getCustomTextStyle(
                fontSize: 16,
                color: AppColors.black,
                weight: FontWeight.w500,
              ),
              hintStyle: AppThemes.getCustomTextStyle(
                fontSize: 16,
                color: AppColors.greyAd,
                weight: FontWeight.w500,
              ),
              prefixIcon: Icon(
                _getIconForMode(),
                color: AppColors.black,
              ),
              suffixIcon: const Icon(
                Icons.arrow_drop_down,
                color: AppColors.black,
              ),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.textFieldBorderColor, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.textFieldBorderColor, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.textFieldBorderColor, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
        child: Text(
          initialDateTime != null ? displayText : hintText ?? 'Select date and time',
          style: textStyle ??
              AppThemes.inter(
                fontSize: 16,
                color: initialDateTime != null
                    ? AppColors.black
                    : AppColors.textFieldHintColor,
                fontWeight: FontWeight.w400,
              ),
        ),
      ),
    );
  }

  IconData _getIconForMode() {
    switch (mode) {
      case DateTimePickerMode.date:
        return Icons.calendar_today;
      case DateTimePickerMode.time:
        return Icons.access_time;
      case DateTimePickerMode.dateTime:
        return Icons.event;
    }
  }

  Future<void> _showDateTimePicker(BuildContext context, DateTime initialDateTime) async {
    final isIOS = Platform.isIOS;

    if (isIOS) {
      await _showCupertinoDateTimePicker(context, initialDateTime);
    } else {
      await _showMaterialDateTimePicker(context, initialDateTime);
    }
  }

  // iOS Cupertino Style DateTime Picker
  Future<void> _showCupertinoDateTimePicker(
      BuildContext context,
      DateTime initialDateTime,
      ) async {
    DateTime? selectedDateTime = initialDateTime;

    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              // Header with Cancel and Done buttons
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground.resolveFrom(context),
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.separator.resolveFrom(context),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        Label.cancel,
                        style: AppThemes.getCustomTextStyle(
                          fontSize: 16,
                          color: AppColors.black,
                          weight: FontWeight.w400,
                        ),
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () {
                        if (selectedDateTime != null) {
                          onDateTimeSelected?.call(selectedDateTime!);
                        }
                        Navigator.of(context).pop();
                      },
                      child:  Text(
                        Label.done,
                        style: AppThemes.getCustomTextStyle(
                          fontSize: 16,
                          color: AppColors.black,
                          weight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // DateTime Picker
              Expanded(
                child: CupertinoDatePicker(
                  mode: _getCupertinoMode(),
                  initialDateTime: initialDateTime,
                  use24hFormat: use24HourFormat,
                  minimumDate: firstDate,
                  maximumDate: lastDate,
                  onDateTimeChanged: (DateTime newDateTime) {
                    selectedDateTime = newDateTime;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  CupertinoDatePickerMode _getCupertinoMode() {
    switch (mode) {
      case DateTimePickerMode.date:
        return CupertinoDatePickerMode.date;
      case DateTimePickerMode.time:
        return CupertinoDatePickerMode.time;
      case DateTimePickerMode.dateTime:
        return CupertinoDatePickerMode.dateAndTime;
    }
  }

  // Android Material Style DateTime Picker
  Future<void> _showMaterialDateTimePicker(
      BuildContext context,
      DateTime initialDateTime,
      ) async {
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    switch (mode) {
      case DateTimePickerMode.date:
        selectedDate = await _showMaterialDatePicker(context, initialDateTime);
        if (selectedDate != null) {
          onDateTimeSelected?.call(selectedDate);
        }
        break;

      case DateTimePickerMode.time:
        selectedTime = await _showMaterialTimePicker(
          context,
          TimeOfDay.fromDateTime(initialDateTime),
        );
        if (selectedTime != null) {
          final dateTime = DateTime(
            initialDateTime.year,
            initialDateTime.month,
            initialDateTime.day,
            selectedTime.hour,
            selectedTime.minute,
          );
          onDateTimeSelected?.call(dateTime);
        }
        break;

      case DateTimePickerMode.dateTime:
      // First pick date
        selectedDate = await _showMaterialDatePicker(context, initialDateTime);
        if (selectedDate == null) return;

        // Then pick time
        selectedTime = await _showMaterialTimePicker(
          context,
          TimeOfDay.fromDateTime(initialDateTime),
        );
        if (selectedTime == null) return;

        // Combine date and time
        final dateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        onDateTimeSelected?.call(dateTime);
        break;
    }
  }

  Future<DateTime?> _showMaterialDatePicker(
      BuildContext context,
      DateTime initialDate,
      ) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              cancelButtonStyle: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll<Color>(AppColors.black)
              ),
              dayForegroundColor: WidgetStatePropertyAll<Color>(AppColors.black),
              dayOverlayColor: WidgetStatePropertyAll<Color>(Colors.transparent),
              surfaceTintColor: AppColors.black,
              confirmButtonStyle: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll<Color>(AppColors.black)
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  Future<TimeOfDay?> _showMaterialTimePicker(
      BuildContext context,
      TimeOfDay initialTime,
      ) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              cancelButtonStyle: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll<Color>(AppColors.black)
              ),
              confirmButtonStyle: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll<Color>(AppColors.black)
              ),
              dialHandColor: AppColors.black,
              hourMinuteColor: AppColors.black,
              hourMinuteTextColor: AppColors.white
            ),
          ),
          child: child!,
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    switch (mode) {
      case DateTimePickerMode.date:
        return DateFormat('MMM dd, yyyy').format(dateTime);
      case DateTimePickerMode.time:
        if (use24HourFormat) {
          return DateFormat('HH:mm').format(dateTime);
        } else {
          return DateFormat('hh:mm a').format(dateTime);
        }
      case DateTimePickerMode.dateTime:
        if (use24HourFormat) {
          return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
        } else {
          return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
        }
    }
  }
}

// Enum for picker modes
enum DateTimePickerMode {
  date,
  time,
  dateTime,
}
