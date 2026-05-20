import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../vm/tourism_models.dart';

const tourismMotionDuration = Duration(milliseconds: 220);
const tourismMotionCurve = Curves.easeOutCubic;

const tourismContentMaxWidth = 680.0;
const tourismAppMaxWidth = 780.0;
const tourismSpace1 = 4.0;
const tourismSpace2 = 8.0;
const tourismSpace3 = 12.0;
const tourismSpace4 = 16.0;
const tourismSpace5 = 20.0;
const tourismSpace6 = 24.0;
const tourismRadiusMd = 18.0;
const tourismRadiusLg = 24.0;

const tourismPageColor = Color(0xfff3f8f4);
const tourismSurfaceColor = Color(0xfff8fcf8);
const tourismSurfaceSoftColor = Color(0xffeff7f1);
const tourismChatColor = Color(0xffdcece2);
const tourismPrimaryColor = Color(0xff146c4e);
const tourismPrimaryContainerColor = Color(0xffbdebd2);
const tourismInkColor = Color(0xff14211a);
const tourismMutedColor = Color(0xff4b5f54);
const tourismWarnColor = Color(0xff755900);
const tourismWarnBgColor = Color(0xfffff3c9);
const tourismDangerColor = Color(0xffb3261e);
const tourismLineColor = Color(0x2914211a);

const tourismTitleStyle = TextStyle(
  color: tourismInkColor,
  fontSize: 16,
  fontWeight: FontWeight.w800,
  height: 1.35,
  letterSpacing: 0,
);

const tourismBodyStyle = TextStyle(
  color: tourismInkColor,
  fontSize: 14,
  height: 1.55,
  letterSpacing: 0,
);

const tourismSecondaryStyle = TextStyle(
  color: tourismMutedColor,
  fontSize: 13,
  height: 1.5,
  letterSpacing: 0,
);

const tourismCaptionStyle = TextStyle(
  color: tourismMutedColor,
  fontSize: 12,
  fontWeight: FontWeight.w800,
  height: 1.35,
  letterSpacing: 0,
);

enum TourismDeviceClass { phone, tablet, expanded }

class TourismLayoutMetrics {
  const TourismLayoutMetrics({
    required this.deviceClass,
    required this.appMaxWidth,
    required this.contentMaxWidth,
    required this.shellMargin,
    required this.viewportPadding,
    required this.composerPadding,
    required this.cardMediaHeight,
    required this.optionSheetMaxWidth,
    required this.optionSheetHeightRatio,
  });

  final TourismDeviceClass deviceClass;
  final double appMaxWidth;
  final double contentMaxWidth;
  final double shellMargin;
  final EdgeInsets viewportPadding;
  final EdgeInsets composerPadding;
  final double cardMediaHeight;
  final double optionSheetMaxWidth;
  final double optionSheetHeightRatio;

  bool get isPhone => deviceClass == TourismDeviceClass.phone;

  static TourismLayoutMetrics fromWidth(double width) {
    if (width < 600) {
      return const TourismLayoutMetrics(
        deviceClass: TourismDeviceClass.phone,
        appMaxWidth: double.infinity,
        contentMaxWidth: tourismContentMaxWidth,
        shellMargin: 0,
        viewportPadding: EdgeInsets.all(tourismSpace3),
        composerPadding: EdgeInsets.fromLTRB(
          tourismSpace4,
          tourismSpace2,
          tourismSpace4,
          tourismSpace4,
        ),
        cardMediaHeight: 132,
        optionSheetMaxWidth: double.infinity,
        optionSheetHeightRatio: 0.78,
      );
    }
    if (width < 1024) {
      return const TourismLayoutMetrics(
        deviceClass: TourismDeviceClass.tablet,
        appMaxWidth: 860,
        contentMaxWidth: 720,
        shellMargin: tourismSpace5,
        viewportPadding: EdgeInsets.all(tourismSpace4),
        composerPadding: EdgeInsets.fromLTRB(
          tourismSpace4,
          tourismSpace2,
          tourismSpace4,
          tourismSpace5,
        ),
        cardMediaHeight: 148,
        optionSheetMaxWidth: 720,
        optionSheetHeightRatio: 0.72,
      );
    }
    return const TourismLayoutMetrics(
      deviceClass: TourismDeviceClass.expanded,
      appMaxWidth: 920,
      contentMaxWidth: 760,
      shellMargin: tourismSpace6,
      viewportPadding: EdgeInsets.all(tourismSpace4),
      composerPadding: EdgeInsets.fromLTRB(
        tourismSpace4,
        tourismSpace2,
        tourismSpace4,
        tourismSpace5,
      ),
      cardMediaHeight: 156,
      optionSheetMaxWidth: 760,
      optionSheetHeightRatio: 0.7,
    );
  }
}

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
    final layout = TourismLayoutMetrics.fromWidth(
      MediaQuery.sizeOf(context).width,
    );
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: layout.contentMaxWidth),
        child: AnimatedContainer(
          duration: tourismMotionDuration,
          curve: tourismMotionCurve,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: tourismSpace3),
          padding: const EdgeInsets.all(tourismSpace4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(tourismRadiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
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
      PillTone.warn => tourismWarnColor,
      PillTone.error => tourismDangerColor,
      PillTone.normal => tourismMutedColor,
    };
    final bg = switch (tone) {
      PillTone.warn => tourismWarnBgColor,
      PillTone.error => const Color(0xffffdad6),
      PillTone.normal => tourismSurfaceSoftColor,
    };
    return Container(
      constraints: const BoxConstraints(minHeight: 32),
      padding: const EdgeInsets.symmetric(
        horizontal: tourismSpace3,
        vertical: tourismSpace2,
      ),
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
          height: 1.25,
          letterSpacing: 0,
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
      margin: const EdgeInsets.only(bottom: tourismSpace2),
      padding: const EdgeInsets.all(tourismSpace2),
      decoration: BoxDecoration(
        color: tourismSurfaceSoftColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33146c4e)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: tourismSpace2,
        children: [
          TourismPill(text: label),
          Expanded(
            child: Text(
              value,
              style: tourismCaptionStyle.copyWith(fontWeight: FontWeight.w700),
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
      padding: const EdgeInsets.only(bottom: tourismSpace2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: tourismSpace2,
        children: [
          SizedBox(width: 64, child: Text(label, style: tourismCaptionStyle)),
          Expanded(
            child: Text(
              value,
              style: tourismCaptionStyle.copyWith(
                color: tourismInkColor,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
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
