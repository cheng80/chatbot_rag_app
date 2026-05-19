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
          color: const Color(0xff146c4e),
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
