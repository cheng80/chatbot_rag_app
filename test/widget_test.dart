import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chatbot_rag_app/app.dart';
import 'package:chatbot_rag_app/vm/app_config.dart';
import 'package:chatbot_rag_app/vm/tourism_option_builder.dart';

void main() {
  testWidgets('renders converted tourism chat app', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: TourismChatApp()));
    await tester.pump();

    expect(find.text('무장애 관광 상담'), findsOneWidget);
    expect(find.text('답변'), findsOneWidget);
    expect(find.text('추천 카드', skipOffstage: false), findsOneWidget);
    expect(find.byTooltip('전송'), findsOneWidget);
  });

  test('option builder matches web query contract', () {
    final message = buildOptionFlowMessage(
      area: '서울',
      sigungu: '강남구',
      conditions: ['wheelchair', 'restroom'],
      preferences: [],
      exclusions: [],
      intensity: 'required',
      expansion: 'conditional',
    );

    expect(message, '서울 강남구에서 휠체어 접근과 장애인 화장실 모두 있는 관광지 추천해줘. 부족하면 서울 전체로 넓혀줘');
  });

  test('API base can target deployed FastAPI server', () {
    expect(
      AppConfig.normalizeApiBase('https://tourism-api.example.com/'),
      'https://tourism-api.example.com',
    );
  });
}
