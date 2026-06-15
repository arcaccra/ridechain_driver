import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LightStatusBar extends StatelessWidget {
  final Widget child;
  const LightStatusBar({super.key, required this.child});

  @override
  /// Builds a widget that wraps its child in an
  /// [AnnotatedRegion] with a [SystemUiOverlayStyle] that
  /// sets the status bar and navigation bar colors to white, and
  /// the brightness of both to dark.
  ///
  /// The child widget is wrapped in a [SafeArea] to ensure that
  /// it is not obscured by the system UI.
  ///
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: SafeArea(child: child),
    );
  }
}