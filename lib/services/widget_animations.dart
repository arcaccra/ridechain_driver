

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

extension WidgetAnimationsExtension on Widget {
  // Base animation with slide from top and fade-in effect
  Animate baseSlideFade({
    Duration slideDuration = const Duration(seconds: 1),
    Duration fadeDuration = const Duration(milliseconds: 500),
    Duration delay = const Duration(milliseconds: 200),
    Offset slideBegin = const Offset(0, -0.3),
    Offset slideEnd = const Offset(0, 0),
    Curve slideCurve = Curves.easeOutBack,
    double fadeBegin = 0.0,
    double fadeEnd = 1.0,
  }) {
    return Animate(
      effects: [
        SlideEffect(
          begin: slideBegin,
          end: slideEnd,
          duration: slideDuration,
          curve: slideCurve,
        ),
        FadeEffect(
          begin: fadeBegin,
          end: fadeEnd,
          duration: fadeDuration,
          delay: delay,
        ),
      ],
    );
  }

  AnimateList baseSlideFadeList({
    Duration slideDuration = const Duration(seconds: 1),
    Duration fadeDuration = const Duration(milliseconds: 500),
    Duration delay = const Duration(milliseconds: 200),
    Offset slideBegin = const Offset(0, 0.3), // Start from bottom
    Offset slideEnd = const Offset(0, 0), // End at original position
    Curve slideCurve = Curves.easeOutBack,
    double fadeBegin = 0.0,
    double fadeEnd = 1.0,
    Duration listItemDelay = const Duration(milliseconds: 100),
    List<Widget> children = const [] // Delay between items
  }) {
    return AnimateList(
      effects: [
        SlideEffect(
          begin: slideBegin,
          end: slideEnd,
          duration: slideDuration,
          curve: slideCurve,
        ),
        FadeEffect(
          begin: fadeBegin,
          end: fadeEnd,
          duration: fadeDuration,
          delay: delay,
        ),
      ],
      interval: listItemDelay, children: children, // Staggered delay for each list item
    );
  }


  // Scale animation with optional delay and curve
  Animate scaleIn({
    Duration duration = const Duration(milliseconds: 600),
    Duration delay = const Duration(milliseconds: 200),
    Curve curve = Curves.easeOut,
    double beginScale = 0.0,
    double endScale = 1.0,
  }) {
    return Animate(
      effects: [
        ScaleEffect(
          begin: Offset(beginScale, beginScale),
          end: Offset(endScale, endScale),
          duration: duration,
          curve: curve,
        ),
      ],
    );
  }

  // Rotate animation with customizable angle
  Animate rotate({
    Duration duration = const Duration(milliseconds: 800),
    Duration delay = const Duration(milliseconds: 200),
    Curve curve = Curves.easeInOut,
    double beginAngle = 0.0,
    double endAngle = 1.0,
  }) {
    return Animate(
      effects: [
        RotateEffect(
          begin: beginAngle,
          end: endAngle,
          duration: duration,
          curve: curve,
          delay: delay,
        ),
      ],
    );
  }

  // Combined animation: slide + fade + scale
  Animate combined({
    Duration slideDuration = const Duration(seconds: 1),
    Duration fadeDuration = const Duration(milliseconds: 500),
    Duration scaleDuration = const Duration(milliseconds: 600),
    Duration delay = const Duration(milliseconds: 200),
    Offset slideBegin = const Offset(0, -0.3),
    Offset slideEnd = const Offset(0, 0),
    Curve slideCurve = Curves.easeOutBack,
    double fadeBegin = 0.0,
    double fadeEnd = 1.0,
    double scaleBegin = 0.8,
    double scaleEnd = 1.0,
  }) {
    return Animate(
      effects: [
        SlideEffect(
          begin: slideBegin,
          end: slideEnd,
          duration: slideDuration,
          curve: slideCurve,
        ),
        FadeEffect(
          begin: fadeBegin,
          end: fadeEnd,
          duration: fadeDuration,
          delay: delay,
        ),
        ScaleEffect(
          begin: Offset(scaleBegin, scaleBegin),
          end: Offset(scaleEnd, scaleEnd),
          duration: scaleDuration,
          delay: delay,
        ),
      ],
    );
  }

  // NEW: Slide from left with fade-in
  Animate slideFromLeft({
    Duration slideDuration = const Duration(seconds: 1),
    Duration fadeDuration = const Duration(milliseconds: 500),
    Duration delay = const Duration(milliseconds: 200),
    Offset slideBegin = const Offset(-0.3, 0),
    Offset slideEnd = const Offset(0, 0),
    Curve slideCurve = Curves.easeOutBack,
    double fadeBegin = 0.0,
    double fadeEnd = 1.0,
  }) {
    return Animate(
      effects: [
        SlideEffect(
          begin: slideBegin,
          end: slideEnd,
          duration: slideDuration,
          curve: slideCurve,
        ),
        FadeEffect(
          begin: fadeBegin,
          end: fadeEnd,
          duration: fadeDuration,
          delay: delay,
        ),
      ],
    );
  }

  // NEW: Slide from right with fade-in
  Animate slideFromRight({
    Duration slideDuration = const Duration(seconds: 1),
    Duration fadeDuration = const Duration(milliseconds: 500),
    Duration delay = const Duration(milliseconds: 200),
    Offset slideBegin = const Offset(0.3, 0),
    Offset slideEnd = const Offset(0, 0),
    Curve slideCurve = Curves.easeOutBack,
    double fadeBegin = 0.0,
    double fadeEnd = 1.0,
  }) {
    return Animate(
      effects: [
        SlideEffect(
          begin: slideBegin,
          end: slideEnd,
          duration: slideDuration,
          curve: slideCurve,
        ),
        FadeEffect(
          begin: fadeBegin,
          end: fadeEnd,
          duration: fadeDuration,
          delay: delay,
        ),
      ],
    );
  }

  // NEW: Flip animation on X-axis
  Animate flipX({
    Duration duration = const Duration(seconds: 1),
    Duration delay = const Duration(milliseconds: 200),
    Curve curve = Curves.easeOutBack,
    double beginAngle = 1.0,
    double endAngle = 0.0,
  }) {
    return Animate(
      effects: [
        FlipEffect(
          direction: Axis.horizontal,
          begin: beginAngle,
          end: endAngle,
          duration: duration,
          curve: curve,
          delay: delay,
        ),
      ],
    );
  }

  // NEW: Flip animation on Y-axis
  Animate flipY({
    Duration duration = const Duration(seconds: 1),
    Duration delay = const Duration(milliseconds: 200),
    Curve curve = Curves.easeOutBack,
    double beginAngle = 1.0,
    double endAngle = 0.0,
  }) {
    return Animate(
      effects: [
        FlipEffect(
          direction: Axis.vertical,
          begin: beginAngle,
          end: endAngle,
          duration: duration,
          curve: curve,
          delay: delay,
        ),
      ],
    );
  }

  // NEW: Shimmer effect
  Animate shimmer({
    Duration duration = const Duration(seconds: 1),
    Duration delay = const Duration(milliseconds: 200),
    Curve curve = Curves.easeOutBack,
    Color color = Colors.white,
    double blend = 0.5,
  }) {
    return Animate(
      effects: [
        ShimmerEffect(
          duration: duration,
          delay: delay,
          curve: curve,
          color: color,
          blendMode: BlendMode.srcIn,
        ),
      ],
    );
  }

  // NEW: Shake animation
  Animate shake({
    Duration duration = const Duration(seconds: 1),
    Duration delay = const Duration(milliseconds: 200),
    Curve curve = Curves.easeOutBack,
    double hz = 10.0,
    Offset offset = const Offset(5, 0),
  }) {
    return Animate(
      effects: [
        ShakeEffect(
          duration: duration,
          delay: delay,
          curve: curve,
          hz: hz,
          offset: offset,
        ),
      ],
    );
  }
}