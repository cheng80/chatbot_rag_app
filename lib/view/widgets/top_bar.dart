import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.showDebug,
    required this.onDebugChanged,
    required this.onHelp,
  });

  final bool showDebug;
  final ValueChanged<bool> onDebugChanged;
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffbdebd2),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xff146c4e),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'T',
              style: TextStyle(
                color: Color(0xffd9f8e6),
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '무장애 관광 상담',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                Text(
                  '조건에 맞는 관광지를 카드로 추천합니다.',
                  style: TextStyle(fontSize: 12, color: Color(0xaa000000)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => onDebugChanged(!showDebug),
            icon: Icon(showDebug ? Icons.bug_report : Icons.person_outline),
            tooltip: showDebug ? '개발 정보 숨기기' : '개발 정보 보기',
          ),
          IconButton(
            onPressed: onHelp,
            icon: const Icon(Icons.help_outline),
            tooltip: '도움말',
          ),
        ],
      ),
    );
  }
}
