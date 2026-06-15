import 'package:flutter/material.dart';

import 'dot_indicator_widget.dart';


class IndicatorAndSkip extends StatelessWidget {
  const IndicatorAndSkip({super.key, required this.page, this.onTap});

  final int page;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 16),
      child: DotIndicatorWidget(page: page, dotCount: 3),
    );
  }
}