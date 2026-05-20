import 'package:flutter/material.dart';

import 'common_widgets.dart';

class ToastBanner extends StatelessWidget {
  const ToastBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return TourismAnimatedEntrance(
      child: AnimatedSwitcher(
        duration: tourismMotionDuration,
        child: Material(
          key: ValueKey(message),
          color: tourismPrimaryColor,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: tourismSpace4,
              vertical: tourismSpace3,
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                height: 1.35,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
