

import 'dart:async';
import 'dart:ui' as ui;
import 'package:dotted_line_flutter/dotted_line_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'core_constants/colors.dart';

abstract class Utils {


  //load images in future before as app loads
  static Future<ui.Image> loadUiImage(String assetPath) async{
    final ByteData data = await rootBundle.load(assetPath);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }

  //get regex for email validation
  static RegExp emailRegex = RegExp(r"^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$");

  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }


  //static const divider
  static Widget divider({double width = 100, Color? color}) => SizedBox(
    width: width,
    child: DottedLine(
      axis: Axis.horizontal,
      lineThickness: 1,
      dashGap: 4,
      height: 1,
      dashWidth: 6,
      shadowBlurRadius: 0,
      shadowColor: Colors.transparent,
      colors: [color ?? AppColors.textFieldBorderColor],
    ),
  );

  //convert time to date time
  static DateTime timeToDateTime(TimeOfDay time, DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  static bool isValidTimeRange(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return endMinutes > startMinutes;
  }

  //TODO:Change to same moments
  static bool isTripDue(DateTime tripStartDate){
    DateTime todaysDate = DateTime.now();
    return tripStartDate.isBefore(todaysDate);
  }

  static String formatDateTime(DateTime date) {
    String formatted = DateFormat('MMM d, h:mma').format(date);
    return formatted;
  }

}