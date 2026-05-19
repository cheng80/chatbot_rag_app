import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../vm/tourism_models.dart';

const tourismMotionDuration = Duration(milliseconds: 220);
const tourismMotionCurve = Curves.easeOutCubic;

class TourismAnimatedEntrance extends StatelessWidget {
  const TourismAnimatedEntrance({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: tourismMotionDuration,
      curve: tourismMotionCurve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class TourismPanel extends StatelessWidget {
  const TourismPanel({
    super.key,
    required this.child,
    this.color = Colors.white,
  });

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: tourismMotionDuration,
      curve: tourismMotionCurve,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class TourismPill extends StatelessWidget {
  const TourismPill({
    super.key,
    required this.text,
    this.tone = PillTone.normal,
  });

  final String text;
  final PillTone tone;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      PillTone.warn => const Color(0xff755900),
      PillTone.error => const Color(0xffb3261e),
      PillTone.normal => const Color(0xff5a6d62),
    };
    final bg = switch (tone) {
      PillTone.warn => const Color(0xfffff3c9),
      PillTone.error => const Color(0xffffdad6),
      PillTone.normal => const Color(0xffeff7f1),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class SourcePill extends StatelessWidget {
  const SourcePill({super.key, required this.source});

  final TourismSource source;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(source.title),
      onPressed: source.url == null
          ? null
          : () => launchUrl(Uri.parse(source.url!)),
    );
  }
}

class EvidenceRow extends StatelessWidget {
  const EvidenceRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xffeff7f1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x33146c4e)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8,
        children: [
          TourismPill(text: label),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Color(0xff5a6d62),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailLine extends StatelessWidget {
  const DetailLine({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 58,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Color(0xff5a6d62),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

class CardMediaFallback extends StatelessWidget {
  const CardMediaFallback({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xffe7f2ea), Color(0xfffaf8ec)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.place_outlined,
          color: Theme.of(context).colorScheme.primary,
          size: 34,
        ),
      ),
    );
  }
}

enum PillTone { normal, warn, error }
