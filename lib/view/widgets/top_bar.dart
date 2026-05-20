import 'package:flutter/material.dart';

import 'common_widgets.dart';

class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.showDebug,
    required this.allowDebug,
    required this.onDebugChanged,
    required this.onHelp,
  });

  final bool showDebug;
  final bool allowDebug;
  final ValueChanged<bool> onDebugChanged;
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    final layout = TourismLayoutMetrics.fromWidth(
      MediaQuery.sizeOf(context).width,
    );
    final avatarSize = layout.isPhone ? 40.0 : 44.0;
    final titleSize = layout.isPhone ? 18.0 : 20.0;
    final actionSize = layout.isPhone ? 40.0 : 44.0;
    return Container(
      color: tourismPrimaryContainerColor,
      padding: EdgeInsets.fromLTRB(
        tourismSpace4,
        layout.isPhone ? tourismSpace2 : tourismSpace3,
        tourismSpace3,
        layout.isPhone ? tourismSpace2 : tourismSpace3,
      ),
      child: Row(
        spacing: layout.isPhone ? tourismSpace2 : tourismSpace3,
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tourismPrimaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'T',
              style: TextStyle(
                color: Color(0xffd9f8e6),
                fontWeight: FontWeight.w900,
                fontSize: layout.isPhone ? 17 : 18,
                height: 1,
                letterSpacing: 0,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: tourismSpace1,
              children: [
                Text(
                  '무장애 관광 상담',
                  style: TextStyle(
                    color: tourismInkColor,
                    fontSize: titleSize,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    letterSpacing: 0,
                  ),
                ),
                const Text(
                  '조건에 맞는 관광지를 카드로 추천합니다.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tourismCaptionStyle,
                ),
              ],
            ),
          ),
          if (allowDebug)
            SizedBox.square(
              dimension: actionSize,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: layout.isPhone ? 24 : 26,
                onPressed: () => onDebugChanged(!showDebug),
                icon: Icon(showDebug ? Icons.bug_report : Icons.person_outline),
                tooltip: showDebug ? '개발 정보 숨기기' : '개발 정보 보기',
              ),
            ),
          SizedBox.square(
            dimension: actionSize,
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: layout.isPhone ? 24 : 26,
              onPressed: onHelp,
              icon: const Icon(Icons.help_outline),
              tooltip: '도움말',
            ),
          ),
        ],
      ),
    );
  }
}
