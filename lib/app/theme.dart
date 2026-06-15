

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/core_constants/colors.dart';

enum AppTheme {
  lightTheme, darkTheme
}

class AppThemes {
  static final appThemeData = {
    //create the dark theme
    //create the light theme
    AppTheme.darkTheme: ThemeData(
      colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppColors.white,
          secondary: AppColors.primaryColor
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primaryColor,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: AppColors.white,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light
        ),
      ),
      useMaterial3: true,
      //brightness: Brightness.dark,
      dividerColor: AppColors.borderColor,
      fontFamily: 'Inter',
    )
  };

  //---------------------------------------------------------------------------
  // appTheme constants

  //---------------------------------------------------------------------------
  //padding
  static const appPaddingSymmetricSmall = EdgeInsets.symmetric(horizontal: 8, vertical: 8);
  static const appPaddingSymmetricMedium = EdgeInsets.symmetric(horizontal: 12, vertical: 12);
  static const appPaddingSymmetricLarge = EdgeInsets.symmetric(horizontal: 16, vertical: 16);


  //---------------------------------------------------------------------------
  //text styles
  //
  static TextStyle outfit({double? fontSize, FontWeight? fontWeight, Color? color, double? height, double? spacing}) => GoogleFonts.outfit(fontSize: fontSize ?? 12, fontWeight: fontWeight ?? FontWeight.normal, color: color ?? AppColors.primaryColor, height: height, letterSpacing: spacing);
  static TextStyle sora({double? fontSize, FontWeight? fontWeight, Color? color, double? height, double? spacing}) => GoogleFonts.sora(fontSize: fontSize ?? 12, fontWeight: fontWeight ?? FontWeight.normal, color: color ?? AppColors.primaryColor, height: height, letterSpacing: spacing);
  static TextStyle inter({double? fontSize, FontWeight? fontWeight, Color? color, double? height, double? spacing}) => GoogleFonts.inter(fontSize: fontSize ?? 12, fontWeight: fontWeight ?? FontWeight.normal, color: color ?? AppColors.primaryColor, height: height, letterSpacing: spacing);


  static const appOutFitSmallStyle = TextStyle(fontSize: 12, fontFamily: "Outfit", color: AppColors.primaryColor);
  static const appOutFitSmallMedium = TextStyle(fontSize: 16, fontFamily: "Outfit", color: AppColors.primaryColor);
  static const appOutFitSmallLarge = TextStyle(fontSize: 20, fontFamily: "Outfit", color: AppColors.primaryColor);

  static const appBeauSansSmall = TextStyle(fontSize: 12, fontFamily: "BeauSans", color: AppColors.primaryColor);
  static const appBeauSansMedium = TextStyle(fontSize: 16, fontFamily: "BeauSans", color: AppColors.primaryColor);
  static const appBeauSansLarge = TextStyle(fontSize: 20, fontFamily: "BeauSans", color: AppColors.primaryColor);

  static const appInterSmallStyle = TextStyle(fontSize: 12, fontFamily: "Inter", color: AppColors.primaryColor);
  static const appInterSmallMedium = TextStyle(fontSize: 16, fontFamily: "Inter", color: AppColors.primaryColor);
  static const appInterSmallLarge = TextStyle(fontSize: 20, fontFamily: "Inter", color: AppColors.primaryColor);

  //getCustomTextStyle
  static getCustomTextStyle({String? fontFamily, double? fontSize, Color? color, double? lineHeight, FontWeight? weight}) {
    return TextStyle(
      fontFamily: fontFamily ?? "BeauSans",
      color: color ?? AppColors.primaryColor,
      fontSize: fontSize ?? 16,
      fontWeight: weight ?? FontWeight.w500,
      height: lineHeight ?? 1
    );
  }

  //---------------------------------------------------------------------------
  //border styles
  static const appRoundedBorderSmall = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    side: BorderSide(color: AppColors.borderColor, width: 1)
  );

  //---------------------------------------------------------------------------
  //card styles
  static const appCardDecorationTheme = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(20.52)),
    color: AppColors.white
  );

  static BoxDecoration appCardDecorationWithShadowTheme = BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(21.24)),
      boxShadow: [
        BoxShadow(
        offset: Offset(0, 3.27),
        blurRadius: 31.6,
        spreadRadius: 0,
        color: AppColors.primaryColor.withValues(alpha: 0.11),
      )],
      color: AppColors.white
  );

  //---------------------------------------------------------------------------
  //button styles
  static const buttonDecorationTheme = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(33.5)),
    color: AppColors.primaryColor,
  );

  static BoxDecoration buttonRoundedBorderDecorationTheme = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(33.5)),
    border: Border.all(width: 2, color: AppColors.primaryColor)
  );

}
