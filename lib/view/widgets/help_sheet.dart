import 'package:flutter/material.dart';

import 'common_widgets.dart';

class HelpSheet extends StatelessWidget {
  const HelpSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          tourismSpace5,
          0,
          tourismSpace5,
          tourismSpace6,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            const Text(
              '사용법과 유의점',
              style: TextStyle(
                color: tourismInkColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.25,
                letterSpacing: 0,
              ),
            ),
            const HelpSection(
              title: '사용법',
              items: [
                '지역 버튼이나 자유 질문으로 범위를 잡습니다.',
                '선택형에서는 지역, 동행 상황, 접근성 조건을 고른 뒤 같은 추천 카드 흐름으로 조회합니다.',
                '중구처럼 여러 시도에 있는 지명은 지역 선택 후속 버튼으로 다시 조회합니다.',
                '선택형으로 만든 질문도 입력창에서 직접 고치거나 조건을 덧붙일 수 있습니다.',
              ],
            ),
            const HelpSection(
              title: '개발 확인',
              items: [
                'DEV 버튼으로 API 주소, Swagger, ReDoc, OpenAPI JSON, 응답 경로 상태를 확인합니다.',
                'release 화면은 --dart-define=DEBUG_UI=false 로 내부 진단 요소와 초기 예시 카드를 숨깁니다.',
              ],
            ),
            const HelpSection(
              title: '유의점',
              items: [
                '운영 시간과 편의시설 위치는 현장 상황에 따라 달라질 수 있습니다.',
                '실제 방문 전에는 공식 안내, 전화, 현장 정보를 다시 확인해야 합니다.',
                '관계 호칭만으로 나이나 이동 조건을 추정하지 않습니다.',
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HelpSection extends StatelessWidget {
  const HelpSection({super.key, required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: tourismSpace4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: tourismSpace2,
        children: [
          Text(title, style: tourismTitleStyle),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: tourismSpace1),
              child: Text('• $item', style: tourismBodyStyle),
            ),
          ),
        ],
      ),
    );
  }
}
